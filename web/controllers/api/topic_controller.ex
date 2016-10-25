defmodule Roman.Api.TopicController do
  use Roman.Web, :controller
  alias Roman.Topic

  plug Guardian.Plug.EnsureAuthenticated,
    [handler: Roman.UnauthorizedError] when action in [:create, :update, :delete]

  def index(conn, _params) do
    topics = Repo.all(Topic)
    render(conn, "index.json", topics: topics)
  end

  def create(conn, %{"topic" => topic_params}) do
    user = Guardian.Plug.current_resource(conn)
    changeset =
      user
      |> build_assoc(:topics)
      |> Topic.changeset(topic_params)

    case Repo.insert(changeset) do
      {:ok, topic} ->
        topic = Map.put(topic, :user_name, user.name)
        conn
        |> put_status(:created)
        |> put_resp_header("location", topic_path(conn, :show, topic))
        |> render("show.json", topic: topic)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Roman.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    topic = Repo.get!(Topic, id)
    render(conn, "show.json", topic: topic)
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    topic = Repo.get!(Topic, id)
    changeset = Topic.changeset(topic, topic_params)

    case Repo.update(changeset) do
      {:ok, topic} ->
        render(conn, "show.json", topic: topic)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Roman.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    topic = Repo.get!(Topic, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(topic)

    send_resp(conn, :no_content, "")
  end
end

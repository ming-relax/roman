defmodule Roman.Api.TopicController do
  use Roman.Web, :controller
  alias Roman.Topic
  alias Roman.Post
  alias Roman.User

  plug Guardian.Plug.EnsureAuthenticated,
    [handler: Roman.UnauthorizedError] when action in [:create, :delete]

  def index(conn, _params) do
    topic_with_last_reply = from t in Topic,
      left_join: topic_replier in User,
      on: t.last_post_user_id == topic_replier.id

    query = from [t, topic_replier] in topic_with_last_reply,
            join: topic_creator in User,
            on: t.user_id == topic_creator.id,
            select: %{
              id: t.id,
              title: t.title,
              creator_user_name: topic_creator.name,
              inserted_at: t.inserted_at,
              updated_at: t.updated_at,
              last_post_user_name: topic_replier.name,
              last_post_inserted_at: t.last_posted_at,
              posts_count: t.posts_count
            }


    topics = Repo.all(query)
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
        topic = Map.put(topic, :creator_user_name, user.name)
        conn
        |> put_status(:created)
        |> put_resp_header("location", topic_path(conn, :show, topic))
        |> render("topic_simple.json", topic: topic)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Roman.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    topic_with_creator = from t in Topic,
                         join: topic_creator in User,
                         on: t.user_id == topic_creator.id,
                         where: t.id == ^id,
                         select: %{
                          id: t.id,
                          title: t.title,
                          content: t.content,
                          creator_user_name: topic_creator.name,
                          inserted_at: t.inserted_at,
                          updated_at: t.updated_at,
                          posts_count: t.posts_count
                         }

    topic = Repo.all(topic_with_creator) |> List.first
    case topic == nil do
      true ->
        conn
        |> put_status(:not_found)
        |> json(%{message: "topic not exist"})
      false ->
        posts_query = from p in Post, where: p.topic_id == ^id
        post_with_creator = from p in posts_query,
                            join: post_creator in User,
                            on: p.user_id == post_creator.id,
                            select: %{
                              id: p.id,
                              content: p.content,
                              topic_id: p.topic_id,
                              post_user_name: post_creator.name,
                              inserted_at: p.inserted_at
                            }


        posts = Repo.all(post_with_creator)
        render(conn, "show.json", %{topic: topic, posts: posts})
    end
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    user = Guardian.Plug.current_resource(conn)
    topic = Repo.get!(Topic, id)
    changeset = Topic.changeset(topic, topic_params)

    case Repo.update(changeset) do
      {:ok, topic} ->
        topic = Map.put(topic, :creator_user_name, user.name)
        render(conn, "topic_simple.json", topic: topic)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Roman.ChangesetView, "error.json", changeset: changeset)
    end
  end
end

defmodule Roman.Api.PostController do
  use Roman.Web, :controller
  alias Roman.Post
  alias Roman.Topic

  plug Guardian.Plug.EnsureAuthenticated, handler: Roman.UnauthorizedError


  def create(conn, %{"post" => post_params, "topic_id" => topic_id}) do
    user = Guardian.Plug.current_resource(conn)
    topic = Repo.get(Topic, topic_id)
    post_changeset =
      user
      |> build_assoc(:posts, topic_id: topic.id)
      |> Post.changeset(post_params)


    case Repo.transaction(fn ->
      post = Repo.insert!(post_changeset)

      topic_changeset = Topic.changeset(
                          topic,
                          %{
                            posts_count: topic.posts_count + 1,
                            last_post_user_id: user.id,
                            last_posted_at: post.inserted_at
                          })

      Repo.update!(topic_changeset)
      post
    end) do
      {:ok, post} ->
        conn
        |> put_status(:created)
        |> render("show.json", post: post)
      {:error, post} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Roman.ChangesetView, "error.json", changeset: post_changeset)
      end
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Repo.get!(Post, id)
    changeset = Post.changeset(post, post_params)

    case Repo.update(changeset) do
      {:ok, post} ->
        render(conn, "show.json", post: post)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Roman.ChangesetView, "error.json", changeset: changeset)
    end
  end
end

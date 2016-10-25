defmodule Roman.Api.PostController do
  use Roman.Web, :controller
  alias Roman.Post
  alias Roman.Topic

  plug Guardian.Plug.EnsureAuthenticated, handler: Roman.UnauthorizedError


  def create(conn, %{"post" => post_params, "topic_id" => topic_id}) do
    user = Guardian.Plug.current_resource(conn)
    case Roman.PostCreator.create(user, topic_id, post_params) do
      {:ok, post} ->
        conn
        |> put_status(:created)
        |> render("show.json", post: post)
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{message: reason})
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

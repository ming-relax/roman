defmodule Roman.Api.PostView do
  use Roman.Web, :view

  def render("index.json", %{posts: posts}) do
    %{data: render_many(posts, Roman.Api.PostView, "post.json")}
  end

  def render("show.json", %{post: post}) do
    %{data: render_one(post, Roman.Api.PostView, "post.json")}
  end

  def render("post.json", %{post: post}) do
    %{id: post.id,
      content: post.content,
      inserted_at: post.inserted_at,
      topic_id: post.topic_id}
  end
end

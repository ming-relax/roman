defmodule Roman.Api.TopicView do
  use Roman.Web, :view

  def render("index.json", %{topics: topics}) do
    render_many(topics, Roman.Api.TopicView, "topic_simple.json")
  end

  def render("show.json", %{topic: topic, posts: posts}) do
    %{
      topic: topic,
      posts: posts
    }
  end

  def render("topic_simple.json", %{topic: topic}) do
    %{id: topic.id,
      title: topic.title,
      creator_user_name: topic.creator_user_name,
      inserted_at: topic.inserted_at,
      updated_at: topic.updated_at,
      last_post_user_name: Map.get(topic, :last_post_user_name),
      last_post_inserted_at: Map.get(topic, :last_post_inserted_at),
      posts_count: topic.posts_count
    }
  end
end

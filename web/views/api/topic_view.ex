defmodule Roman.Api.TopicView do
  use Roman.Web, :view

  def render("index.json", %{topics: topics}) do
    %{data: render_many(topics, Roman.Api.TopicView, "topic.json")}
  end

  def render("show.json", %{topic: topic}) do
    %{data: render_one(topic, Roman.Api.TopicView, "topic.json")}
  end

  def render("topic.json", %{topic: topic}) do
    %{id: topic.id,
      title: topic.title,
      content: topic.content,
      user_id: topic.user_id}
  end
end

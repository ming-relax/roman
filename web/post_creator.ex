defmodule Roman.PostCreator do
  import Ecto
  import Ecto.Query
  alias Roman.Repo
  alias Roman.Topic
  alias Roman.Post

  def create(user, topic_id, post_params) do

    # Update the topic and insert the post inside a transaction with lock
    Repo.transaction(fn ->

      query = from(topic in Topic, where: topic.id == ^topic_id, lock: "FOR UPDATE")
      topic = Repo.all(query) |> List.first

      if topic == nil do
        Repo.rollback(:topic_not_found)
      end

      # Insert the post
      post_changeset =
        user
        |> build_assoc(:posts, %{topic_id: topic.id})
        |> Post.changeset(post_params)

      post = case post_changeset.valid? do
        true  ->
          Repo.insert!(post_changeset)
        false ->
          Repo.rollback(:post_invalid)
      end

      # Update the topic
      topic_changeset = Topic.changeset(
                          topic,
                          %{
                            posts_count: topic.posts_count + 1,
                            last_post_user_id: user.id,
                            last_posted_at: post.inserted_at
                          })

      case topic_changeset.valid? do
        true ->
          Repo.update!(topic_changeset)
        false ->
          Repo.rollback(:topic_invalid)
      end
      post
    end)
  end
end
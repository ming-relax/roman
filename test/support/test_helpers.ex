defmodule Roman.TestHelpers do
  alias Roman.Repo
  alias Roman.Topic
  alias Roman.Post

  use Roman.Web, :controller

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "user#{Base.encode16(:crypto.rand_bytes(8))}",
      password: "supersecret"
    }, attrs)

    %Roman.User{}
    |> Roman.User.registration_changeset(changes)
    |> Repo.insert!()
  end

  def get_jwt(user, conn) do
    new_conn = Guardian.Plug.api_sign_in(conn, user)
    Guardian.Plug.current_token(new_conn)
  end

  def create_user_and_login_the_conn(conn) do
    user = insert_user()
    jwt = get_jwt(user, conn)
    {user, put_req_header(conn, "authorization", "Bearer #{jwt}")}
  end

  def create_topic(user, attrs \\ %{}) do
    topic_params = Dict.merge(
      %{
        title: "Some random title #{Base.encode16(:crypto.rand_bytes(8))}",
        content: "Some random content #{Base.encode16(:crypto.rand_bytes(8))}"
      },
      attrs
    )

    changeset =
      user
      |> build_assoc(:topics)
      |> Topic.changeset(topic_params)

    Repo.insert!(changeset)
  end

  def create_post(user, topic, attrs \\ %{}) do
    post_params = Dict.merge(
      %{
        content: "Some random content #{Base.encode16(:crypto.rand_bytes(8))}",
      },
      attrs
    )

    case Roman.PostCreator.create(user, topic.id, post_params) do
      {:ok, post} ->
        post
      {:error, reason} ->
        raise "error: #{reason}"
    end
  end
end
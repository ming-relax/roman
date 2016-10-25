defmodule Roman.PostControllerTest do
  use Roman.ConnCase

  alias Roman.Post
  alias Roman.Topic

  @valid_attrs %{content: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "POST create" do
    test "returns :unauthorized when jwt is not in header", %{conn: conn} do
      user = insert_user()
      topic = create_topic(user)
      conn = post conn, post_path(conn, :create, topic.id), post: @valid_attrs
      assert json_response(conn, :unauthorized)
    end

    test "creates and renders resource when data is valid", %{conn: conn} do
      topic_user = insert_user()
      topic = create_topic(topic_user)

      {post_user, conn} = create_user_and_login_the_conn(conn)

      conn = post conn, post_path(conn, :create, topic.id), post: @valid_attrs, topic_id: topic.id

      # post is created and returned
      assert json_response(conn, 201)["data"]["id"]
      assert json_response(conn, 201)["data"]["inserted_at"]
      post = Repo.get_by(Post, @valid_attrs)
      assert post
      assert post.user_id
      assert post.topic_id

      # topic info is changed
      topic = Repo.get(Topic, topic.id)
      assert topic.posts_count == 1
      assert topic.last_post_user_id == post_user.id
      assert Ecto.DateTime.to_iso8601(topic.last_posted_at) == json_response(conn, 201)["data"]["inserted_at"]
    end

    # test "does not create post if topic not exist" do

    # end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post conn, topic_path(conn, :create), topic: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    post = Repo.insert! %Post{}
    conn = put conn, post_path(conn, :update, post), post: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Post, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    post = Repo.insert! %Post{}
    conn = put conn, post_path(conn, :update, post), post: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

end

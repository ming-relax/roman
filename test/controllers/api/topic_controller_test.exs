defmodule Roman.TopicControllerTest do
  use Roman.ConnCase

  alias Roman.Topic
  @valid_attrs %{content: "some content", title: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET index" do
    test "lists 0 entry when there is no topic", %{conn: conn} do
      conn = get conn, topic_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end

    test "list all entries when there are topics", %{conn: conn} do
      # create two topics
      {topic_user, conn} = create_user_and_login_the_conn(conn)

      topic_1 = create_topic(topic_user)
      create_topic(topic_user)

      create_post(topic_user, topic_1)

      conn = get conn, topic_path(conn, :index)
      assert json_response(conn, :ok)
    end
  end

  describe "POST create" do
    test "returns :unauthorized when jwt is not in header", %{conn: conn} do
      conn = post conn, topic_path(conn, :create), topic: @valid_attrs
      assert json_response(conn, :unauthorized)
    end

    test "creates and renders resource when data is valid", %{conn: conn} do
      {_user, conn} = create_user_and_login_the_conn(conn)
      conn = post conn, topic_path(conn, :create), topic: @valid_attrs

      assert json_response(conn, 201)["id"]
      assert json_response(conn, 201)["creator_user_name"]
      assert json_response(conn, 201)["inserted_at"]
      assert json_response(conn, 201)["posts_count"] == 0
      assert Repo.get_by(Topic, @valid_attrs)
    end
  end

  test "shows chosen resource", %{conn: conn} do
    # create two topics
    {topic_user, conn} = create_user_and_login_the_conn(conn)
    post_user_1 = insert_user()
    post_user_2 = insert_user()

    topic_1 = create_topic(topic_user)

    create_post(post_user_1, topic_1)
    create_post(post_user_2, topic_1)


    conn = get conn, topic_path(conn, :show, topic_1)
    assert json_response(conn, 200)
    response_data = json_response(conn, 200)
    assert (response_data["topic"]["posts_count"]) == 2
    assert length(response_data["posts"]) == 2
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn = get conn, topic_path(conn, :show, -1)
    assert response(conn, 404)
  end

  # test "updates and renders chosen resource when data is valid", %{conn: conn} do
  #   topic = Repo.insert! %Topic{}
  #   conn = put conn, topic_path(conn, :update, topic), topic: @valid_attrs
  #   assert json_response(conn, 200)["data"]["id"]
  #   assert Repo.get_by(Topic, @valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   topic = Repo.insert! %Topic{}
  #   conn = put conn, topic_path(conn, :update, topic), topic: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  # test "deletes chosen resource", %{conn: conn} do
  #   topic = Repo.insert! %Topic{}
  #   conn = delete conn, topic_path(conn, :delete, topic)
  #   assert response(conn, 204)
  #   refute Repo.get(Topic, topic.id)
  # end
end

defmodule Roman.Api.AuthControllerTest do
  use Roman.ConnCase

  alias Roman.User

  @valid_attrs %{name: "ming", password: "test123"}
  @invalid_attrs %{}


  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "register the user and return a valid jwt", %{conn: conn} do
    conn = post conn, auth_path(conn, :register), user: @valid_attrs
    assert json_response(conn, 200)["data"]["jwt"]
    assert Repo.get_by(User, %{name: @valid_attrs.name})
  end

  test "login the user and return a valid jwt", %{conn: conn} do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    Repo.insert(changeset)

    conn = post conn, auth_path(conn, :login), user: @valid_attrs
    assert json_response(conn, 200)["data"]["jwt"]
  end

end

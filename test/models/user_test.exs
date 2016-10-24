defmodule Roman.UserTest do
  use Roman.ModelCase

  alias Roman.User

  @valid_attrs %{name: "some content", password: "some content"}
  @invalid_attrs %{}

  test "registration_changeset with valid attributes" do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end

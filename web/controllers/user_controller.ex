defmodule Roman.UserController do
  use Roman.Web, :controller
  alias Roman.User

  def new(conn, _params) do
    changeset = User.registration_changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        text conn, "User id #{user.id}"
      {:error, _changeset} ->
        text conn, "Registration Error"
    end
  end
end

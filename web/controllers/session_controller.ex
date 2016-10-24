defmodule Roman.SessionController do
  use Roman.Web, :controller

  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  alias Roman.User

  plug :scrub_params, "user" when action in [:create]

  # login
  def create(conn, %{"user" => user_params}) do
    user = Repo.get_by(User, name: user_params["name"])
    cond do
      user && checkpw(user_params["password"], user.password_hash) ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> text("Login OK")
      user ->
        conn
        |> redirect(to: "/login")
      true ->
        dummy_checkpw
        conn
        |> redirect(to: "/login")
    end
  end


end
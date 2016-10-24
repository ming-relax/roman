defmodule Roman.Api.AuthController do
  use Roman.Web, :controller

  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias Roman.User

  plug :scrub_params, "user" when action in [:create]


  def register(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        new_conn = Guardian.Plug.api_sign_in(conn, user)
        jwt = Guardian.Plug.current_token(new_conn)
        {:ok, claims} = Guardian.Plug.claims(new_conn)
        exp = Map.get(claims, "exp")

        new_conn
        |> put_status(:ok)
        |> render("show.json", jwt: jwt, exp: exp)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Roman.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def login(conn, %{"user" => user_params}) do
    user = Repo.get_by(User, name: user_params["name"])
    cond do
      user && checkpw(user_params["password"], user.password_hash) ->
        new_conn = Guardian.Plug.api_sign_in(conn, user)
        jwt = Guardian.Plug.current_token(new_conn)
        {:ok, claims} = Guardian.Plug.claims(new_conn)
        exp = Map.get(claims, "exp")

        new_conn
        |> put_status(:ok)
        |> render("show.json", jwt: jwt, exp: exp)
      true ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", %{message: "Failed to login"})
    end
  end

end
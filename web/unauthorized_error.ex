defmodule Roman.UnauthorizedError do
  use Roman.Web, :controller

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:unauthorized)
    |> json(%{message: "unauthorized"})
  end
end
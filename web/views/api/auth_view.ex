defmodule Roman.Api.AuthView do
  use Roman.Web, :view

  def render("show.json", %{jwt: jwt, exp: exp}) do
    %{jwt: jwt, exp: exp}
  end

  def render("error.json", %{message: message}) do
    %{message: message}
  end
end

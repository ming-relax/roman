defmodule Roman.PageController do
  use Roman.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

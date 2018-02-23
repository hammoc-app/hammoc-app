defmodule HammocWeb.PageController do
  use HammocWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

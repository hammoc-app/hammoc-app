defmodule HammocWeb.UserController do
  use HammocWeb, :controller

  alias Hammoc.Identity

  plug :require_user when action in [:start, :account]

  def sign_in(conn, _params) do
    users = Identity.get_users(conn.assigns.user_ids)

    render(conn, "sign_in.html", users: users)
  end

  def start(conn, _params) do
    render(conn, "start.html")
  end

  def account(conn, _params) do
    render(conn, "account.html")
  end

  defp require_user(conn = %{assigns: %{user: _user}}, _opts), do: conn

  defp require_user(conn, _opts) do
    conn
    |> redirect(to: "/")
  end
end

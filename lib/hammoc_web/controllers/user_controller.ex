defmodule HammocWeb.UserController do
  use HammocWeb, :controller

  alias Hammoc.Identity
  alias Hammoc.Identity.User

  plug :require_user when action in [:start, :account, :update]

  def sign_in(conn, _params) do
    users = Identity.get_users(conn.assigns.user_ids)

    render(conn, "sign_in.html", users: users)
  end

  def sign_out(conn, params) do
    redirect_to = params["return_to"] || "/"

    conn
    |> delete_session(:user_id)
    |> redirect(to: redirect_to)
  end

  def start(conn, _params) do
    changeset = User.changeset(conn.assigns.user)
    render(conn, "start.html", changeset: changeset)
  end

  def update(conn, params) do
    case Identity.update_user(conn.assigns.user, params["user"]) do
      {:ok, _user} -> redirect(conn, to: "/")
      {:error, errors} -> render(conn, "start.html", user: conn.assigns.user, errors: errors)
    end
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

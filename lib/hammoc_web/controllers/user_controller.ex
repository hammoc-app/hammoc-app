defmodule HammocWeb.UserController do
  use HammocWeb, :controller

  alias Hammoc.Identity
  alias Hammoc.Identity.User

  plug :require_user when action in [:start, :account, :update]

  def choose_user(conn, _params) do
    {:ok, users} = Identity.get_users(get_session(conn, :user_ids))

    render(conn, "choose_user.html", users: users)
  end

  def sign_in(conn, %{"user_id" => user_id}) do
    with user_id in get_session(conn, :user_ids),
         {:ok, user} <- Identity.get_user(user_id) do
      redirect_to = if user.started, do: "/", else: "/start"

      conn
      |> put_session(:user_id, user.id)
      |> delete_session(:user_ids)
      |> redirect(to: redirect_to)
    else
      _ -> redirect(conn, to: "/")
    end
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

  def remove_authentication(conn, %{"authentication_id" => auth_id}) do
    Identity.remove_user_authentication(conn.assigns.user, auth_id)

    redirect(conn, to: "/account")
  end

  defp require_user(conn = %{assigns: %{user: _user}}, _opts), do: conn

  defp require_user(conn, _opts) do
    conn
    |> redirect(to: "/")
  end
end

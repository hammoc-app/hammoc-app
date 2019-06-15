defmodule HammocWeb.AuthController do
  use HammocWeb, :controller

  alias Hammoc.Identity

  plug Ueberauth

  # Use cancelled sign in
  def callback(
        conn = %Plug.Conn{
          assigns: %{
            ueberauth_failure: %Ueberauth.Failure{errors: [%{message_key: "missing_code"}]}
          }
        },
        _params
      ) do
    conn
    |> redirect(to: "/")
  end

  def callback(
        conn = %Plug.Conn{
          assigns: %{ueberauth_failure: %Ueberauth.Failure{errors: [%{message: msg} | _]}}
        },
        _params
      ) do
    conn
    |> put_flash(:error, msg)
    |> redirect(to: "/")
  end

  def callback(conn = %Plug.Conn{assigns: %{ueberauth_auth: auth}}, _params) do
    auth_params =
      auth.info
      |> Map.from_struct()
      |> Map.put(:access_token, auth.credentials.token)
      |> Map.put(:access_token_secret, auth.credentials.secret)

    result =
      Identity.authenticate_via_oauth(conn.assigns[:user], auth.provider, auth.uid, auth_params)

    case result do
      {:ok, [user]} ->
        redirect_to =
          cond do
            conn.assigns[:user] -> "/account"
            !user.started -> "/start"
            true -> "/"
          end

        conn
        |> put_session(:user_id, user.id)
        |> redirect(to: redirect_to)

      {:ok, users} ->
        conn
        |> put_session(:user_ids, Enum.map(users, & &1.id))
        |> redirect(to: "/sign_in")

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: "/")
    end
  end
end

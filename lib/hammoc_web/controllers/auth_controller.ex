defmodule HammocWeb.AuthController do
  use HammocWeb, :controller

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

  def callback(conn = %Plug.Conn{assigns: %{ueberauth_auth: %Ueberauth.Auth{}}}, _params) do
    conn
    |> put_flash(:info, "Successfully authenticated.")
    |> redirect(to: "/")
  end
end

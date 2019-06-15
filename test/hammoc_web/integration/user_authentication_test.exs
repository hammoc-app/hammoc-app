defmodule HammocWeb.UserAuthenticationTest do
  use HammocWeb.IntegrationCase

  alias Test.Support.Mocks.UeberauthCallback
  alias Ueberauth.Auth.Info
  alias Ueberauth.Failure.Error

  test "Successful login, logout, login", %{conn: conn} do
    stub(UeberauthCallback, :result, fn ->
      {:ok, info: %Info{name: "Domingo Santini"}}
    end)

    get(conn, "/")
    |> assert_response(status: 200, path: "/")
    |> follow_link("Sign in with Twitter")
    |> assert_response(status: 200, path: "/start", html: "Domingo Santini")
    |> follow_form(user: %{email: "user@example.com", newsletter: true})
    |> assert_response(status: 200, path: "/", html: "Domingo Santini")
    |> follow_link("Log out", method: "delete")
    |> assert_response(status: 200, path: "/")
    |> refute_response(html: "Domingo Santini")
    |> follow_link("Sign in with Twitter")
    |> assert_response(status: 200, path: "/", html: "Domingo Santini")
  end

  test "User cancelled OAuth", %{conn: conn} do
    stub(UeberauthCallback, :result, fn ->
      {:error, %Error{message: "No code received", message_key: "missing_code"}}
    end)

    get(conn, "/")
    |> assert_response(status: 200, path: "/")
    |> follow_link("Sign in with Twitter")
    |> assert_response(status: 200, path: "/")
    |> refute_response(html: "Domingo Santini")
  end
end

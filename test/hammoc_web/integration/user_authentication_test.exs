defmodule HammocWeb.UserAuthenticationTest do
  use HammocWeb.IntegrationCase

  alias Ueberauth.Auth.Info

  test "Successful login, logout, login", %{conn: conn} do
    Test.Support.Mocks.UeberauthCallback
    |> stub(:result, fn -> {:ok, info: %Info{name: "Domingo Santini"}} end)

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
end

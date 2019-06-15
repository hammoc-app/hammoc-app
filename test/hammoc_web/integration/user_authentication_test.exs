defmodule HammocWeb.UserAuthenticationTest do
  use HammocWeb.IntegrationCase

  alias Test.Support.Mocks.UeberauthCallback
  alias Ueberauth.Auth.Info
  alias Ueberauth.Failure.Error

  describe "Successful login" do
    setup do
      stub(UeberauthCallback, :result, fn ->
        {:ok, info: %Info{name: "Domingo Santini"}}
      end)

      :ok
    end

    test "Login, start, logout, login", %{conn: conn} do
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

    test "Login, skip start, logout, login", %{conn: conn} do
      get(conn, "/")
      |> assert_response(status: 200, path: "/")
      |> follow_link("Sign in with Twitter")
      |> assert_response(status: 200, path: "/start", html: "Domingo Santini")
      |> follow_link("Not now")
      |> assert_response(status: 200, path: "/", html: "Domingo Santini")
      |> follow_link("Log out", method: "delete")
      |> assert_response(status: 200, path: "/")
      |> refute_response(html: "Domingo Santini")
      |> follow_link("Sign in with Twitter")
      |> assert_response(status: 200, path: "/start", html: "Domingo Santini")
    end
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

defmodule HammocWeb.UserAuthenticationTest do
  use HammocWeb.IntegrationCase

  alias Test.Support.Mocks.UeberauthCallback
  alias Ueberauth.Auth.Info
  alias Ueberauth.Failure.Error

  alias Hammoc.Identity.{Authentication, User, UserAuthentication}

  def with_users(_context) do
    other_user = create!(User, authentications: [])
    user = create!(User, authentications: [])

    %{other_user: other_user, user: user}
  end

  def with_user_authentications(context) do
    %{other_user: other_user, user: user} = with_users(context)

    auth = create!(Authentication, uid: "abc123")
    create!(UserAuthentication, user_id: user.id, authentication_id: auth.id)

    other_auth = create!(Authentication)
    create!(UserAuthentication, user_id: other_user.id, authentication_id: other_auth.id)

    %{
      user: %{user | authentications: [auth]},
      other_user: %{other_user | authentications: [other_auth]}
    }
  end

  def successful_oauth(_context) do
    stub(UeberauthCallback, :result, fn ->
      {:ok, info: %Info{name: "Domingo Santini"}}
    end)

    :ok
  end

  def sign_in(conn) do
    conn
    |> get("/auth/twitter")
    |> follow_redirect()
  end

  describe "Successful login" do
    setup :successful_oauth

    test "Login, start, logout, login", %{conn: conn} do
      get(conn, "/")
      |> assert_response(status: 200, path: "/")
      |> sign_in()
      |> assert_response(status: 200, path: "/start", html: "Domingo Santini")
      |> follow_form(user: %{email: "user@example.com", newsletter: true})
      |> assert_response(status: 200, path: "/", html: "Domingo Santini")
      |> follow_link("Log out", method: "delete")
      |> assert_response(status: 200, path: "/")
      |> refute_response(html: "Domingo Santini")
      |> sign_in()
      |> assert_response(status: 200, path: "/", html: "Domingo Santini")
    end

    test "Login, skip start, logout, login", %{conn: conn} do
      get(conn, "/")
      |> assert_response(status: 200, path: "/")
      |> sign_in()
      |> assert_response(status: 200, path: "/start", html: "Domingo Santini")
      |> follow_link("Not now")
      |> assert_response(status: 200, path: "/", html: "Domingo Santini")
      |> follow_link("Log out", method: "delete")
      |> assert_response(status: 200, path: "/")
      |> refute_response(html: "Domingo Santini")
      |> sign_in()
      |> assert_response(status: 200, path: "/start", html: "Domingo Santini")
    end
  end

  describe "Authentication with multiple users" do
    setup :with_user_authentications
    setup :successful_oauth

    setup %{user: %{authentications: [auth]}, other_user: other_user} do
      create!(UserAuthentication, user_id: other_user.id, authentication_id: auth.id)

      :ok
    end

    test "Login, choose user, start", %{conn: conn, user: user, other_user: other_user} do
      get(conn, "/")
      |> assert_response(status: 200, path: "/")
      |> sign_in()
      |> assert_response(
        status: 200,
        path: "/choose_user",
        html: user.email,
        html: other_user.email
      )
      |> follow_form(user_id: user.id)
      |> assert_response(status: 200, path: "/start", html: "Domingo Santini")
    end
  end

  test "User cancelled OAuth", %{conn: conn} do
    stub(UeberauthCallback, :result, fn ->
      {:error, %Error{message: "No code received", message_key: "missing_code"}}
    end)

    get(conn, "/")
    |> assert_response(status: 200, path: "/")
    |> sign_in()
    |> assert_response(status: 200, path: "/")
    |> refute_response(html: "Domingo Santini")
  end
end

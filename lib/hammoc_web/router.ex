defmodule HammocWeb.Router do
  use HammocWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HammocWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/choose_user", UserController, :choose_user
    post "/sign_in", UserController, :sign_in
    delete "/sign_out", UserController, :sign_out
    get "/start", UserController, :start
    put "/update_user", UserController, :update
    get "/account", UserController, :account
    delete "/remove_authentication/:authentication_id", UserController, :remove_authentication
  end

  scope "/auth", HammocWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", HammocWeb do
  #   pipe_through :api
  # end

  defp load_user(conn, _opts) do
    with user_id when is_binary(user_id) <- get_session(conn, :user_id),
         {:ok, user} <- Hammoc.Identity.get_user(user_id) do
      conn
      |> assign(:user, user)
    else
      {:error, error} ->
        conn
        |> put_flash(error, error)

      _ ->
        conn
    end
  end
end

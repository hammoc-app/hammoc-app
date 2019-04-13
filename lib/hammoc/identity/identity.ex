defmodule Hammoc.Identity do
  @moduledoc """
  Manages users and their authentications.
  """

  alias Hammoc.Repo
  alias Hammoc.Identity.{Authentication, User, UserAuthentication}

  def authenticate_via_oauth(nil, provider, uid, params = %{}) do
    with {:ok, auth} <- insert_or_update_auth(provider, uid, params),
         {:ok, auth} <- ensure_user(auth) do
      {:ok, auth.users}
    end
  end

  def authenticate_via_oauth(user = %{id: user_id}, provider, uid, params = %{}) do
    case insert_or_update_auth(provider, uid, params) do
      {:ok, auth = %{users: []}} ->
        {:ok, [%{user | authentications: [auth | user.authentications]}]}

      {:ok, %{users: [%{id: ^user_id}]}} ->
        {:ok, [user]}

      {:ok, %{users: other_users}} ->
        {:ok, Enum.uniq_by([user | other_users], & &1.id)}

      {:error, error} ->
        {:error, error}
    end
  end

  defp insert_or_update_auth(provider, uid, params = %{}) when is_atom(provider) do
    insert_or_update_auth(Atom.to_string(provider), uid, params)
  end

  defp insert_or_update_auth(provider, uid, params = %{}) do
    result =
      case Repo.get_by(Authentication, provider: provider, uid_hash: uid) do
        nil -> %Authentication{provider: provider, uid: uid}
        authentication -> authentication
      end
      |> Authentication.changeset(params)
      |> Repo.insert_or_update()

    with {:ok, auth} <- result do
      {:ok, Repo.preload(auth, :users)}
    end
  end

  defp ensure_user(auth = %Authentication{users: []}) do
    with {:ok, user} <- Repo.insert(%User{}),
         {:ok, _} <-
           Repo.insert(%UserAuthentication{user_id: user.id, authentication_id: auth.id}) do
      {:ok, %{auth | users: [user]}}
    end
  end

  defp ensure_user(auth), do: auth

  def get_users(user_ids) do
    with {:ok, users} <- Repo.get(User, user_ids) do
      {:ok, Repo.preload(users, :authentications)}
    end
  end
end

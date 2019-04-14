defmodule Hammoc.Identity do
  @moduledoc """
  Manages users and their authentications.
  """

  alias Hammoc.Repo
  alias Hammoc.Identity.{Authentication, User, UserAuthentication}

  import Ecto.Query, only: [from: 2]

  def authenticate_via_oauth(nil, provider, uid, params = %{}) do
    with {:ok, auth} <- insert_or_update_auth(provider, uid, params),
         {:ok, auth} <- ensure_auth_has_user(auth) do
      {:ok, auth.users}
    end
  end

  def authenticate_via_oauth(user, provider, uid, params = %{}) do
    with {:ok, auth} <- insert_or_update_auth(provider, uid, params),
         {:ok, _user_auth} <- ensure_user_auth(user.id, auth.id) do
      auths = Enum.uniq_by([auth | user.authentications], & &1.id)

      {:ok, [%{user | authentications: auths}]}
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
      {:ok, Repo.preload(auth, users: :authentications)}
    end
  end

  defp ensure_user_auth(user_id, auth_id) do
    case Repo.get_by(UserAuthentication, user_id: user_id, authentication_id: auth_id) do
      nil ->
        %UserAuthentication{user_id: user_id, authentication_id: auth_id}
        |> Repo.insert()

      user_auth ->
        {:ok, user_auth}
    end
  end

  defp ensure_auth_has_user(auth = %Authentication{users: []}) do
    with {:ok, user} <- Repo.insert(%User{}),
         {:ok, _} <-
           Repo.insert(%UserAuthentication{user_id: user.id, authentication_id: auth.id}) do
      {:ok, %{auth | users: [%{user | authentications: [auth]}]}}
    end
  end

  defp ensure_auth_has_user(auth), do: {:ok, auth}

  def get_user(user_id) do
    with {:ok, users} <- Repo.get(User, user_id) do
      {:ok, Repo.preload(users, :authentications)}
    end
  end

  def get_users(user_ids) do
    Repo.all(
      from u in User,
        where: u.id in ^user_ids,
        preload: [:associations],
        select: u
    )
  end
end

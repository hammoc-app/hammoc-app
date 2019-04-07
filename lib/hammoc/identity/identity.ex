defmodule Hammoc.Identity do
  @moduledoc """
  Manages users and their authentications.
  """

  alias Hammoc.Repo
  alias Hammoc.Identity.{Authentication, User}

  def authenticate_via_oauth(provider, uid, params = %{})
      when is_atom(provider) and is_binary(uid) do
    authenticate_via_oauth(Atom.to_string(provider), uid, params)
  end

  def authenticate_via_oauth(provider, uid, params = %{})
      when is_binary(provider) and is_binary(uid) do
    result =
      case Repo.get_by(Authentication, provider: provider, uid_hash: uid) do
        nil -> %Authentication{provider: provider, uid: uid}
        authentication -> authentication
      end
      |> Authentication.changeset(params)
      |> Repo.insert_or_update()

    with {:ok, authentication} <- result do
      {:ok, Repo.preload(authentication, :users)}
    end
  end
end

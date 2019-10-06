defmodule Hammoc.Ecto.Hashed.PBKDF2 do
  @moduledoc """
  Hashed database field type, derived from `Cloak.Ecto.PBKDF2`.

  The hashing secret is derived from the `secret_key_base` via key derivation itself.
  """

  use Cloak.Ecto.PBKDF2, otp_app: :hammoc

  @key_salt "db hashed field"

  def init(config) do
    key_length = Keyword.fetch!(config, :size)
    key = Hammoc.Crypto.key_for(@key_salt, key_length: key_length)

    {:ok, Keyword.put(config, :secret, key)}
  end

  @impl Ecto.Type
  def embed_as(_), do: :self

  @impl Ecto.Type
  def equal?(term1, term2), do: term1 == term2
end

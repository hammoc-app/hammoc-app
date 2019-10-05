defmodule Hammoc.Vault do
  @moduledoc """
  A `Cloak.Vault` to manage encryption.

  The encryption key is derived from the `secret_key_base` via key derivation.
  """

  use Cloak.Vault, otp_app: :hammoc

  @key_salt "db encrypted field"

  def init(_config) do
    key = Hammoc.Crypto.key_for(@key_salt, key_length: 32, cache: nil)

    {:ok, ciphers: [default: {Cloak.Ciphers.AES.GCM, tag: <<1>>, key: key}]}
  end
end

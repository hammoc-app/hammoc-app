defmodule Hammoc.Vault do
  @moduledoc """
  A `Cloak.Vault` to manage encryption.

  Assumes that you have a `HAMMOC_VAULT_KEY` environment variable
  containing a Base64-encoded key.

  To generate a key:
  ```
  $ iex
  iex> 64 |> :crypto.strong_rand_bytes() |> Base.encode64()
  ```
  """

  use Cloak.Vault, otp_app: :hammoc

  @env_vars ciphers: [
              default:
                {[key: %Util.Config.Var{name: "HAMMOC_VAULT_KEY", transform: &Base.decode64!/1}]}
            ]

  def init(config) do
    Util.Config.merge_environment_variables(config, @env_vars)
  end
end

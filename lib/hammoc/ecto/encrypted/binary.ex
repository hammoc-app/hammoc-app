defmodule Hammoc.Ecto.Encrypted.Binary do
  use Cloak.Ecto.Binary, vault: Hammoc.Vault
end

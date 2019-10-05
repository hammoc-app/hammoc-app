defmodule Hammoc.Ecto.Encrypted.Binary do
  @moduledoc "Encrypted database field type, derived from `Cloak.Ecto.Binary`."

  use Cloak.Ecto.Binary, vault: Hammoc.Vault
end

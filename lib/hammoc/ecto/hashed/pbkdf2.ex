defmodule Hammoc.Ecto.Hashed.PBKDF2 do
  @moduledoc "Hashed database field type, derived from `Cloak.Ecto.PBKDF2`."

  use Cloak.Ecto.PBKDF2, otp_app: :hammoc

  @env_vars secret: %Util.Config.Var{name: "HAMMOC_PBKDF2_SECRET", transform: &Base.decode64!/1}

  def init(config) do
    Util.Config.merge_environment_variables(config, @env_vars)
  end
end

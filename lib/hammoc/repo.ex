defmodule Hammoc.Repo do
  @env_vars url: "DB_URL",
            hostname: "DB_HOST",
            port: "DB_PORT",
            database: "DB_NAME",
            username: "DB_USERNAME",
            password: "DB_PASSWORD"

  use Ecto.Repo,
    otp_app: :hammoc,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    Util.Config.merge_environment_variables(config, @env_vars)
  end
end

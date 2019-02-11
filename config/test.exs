use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hammoc, HammocWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :hammoc, Hammoc.Repo,
  username: "postgres",
  password: "postgres",
  database: "hammoc_test",
  hostname: System.get_env("DB_HOST") || "localhost",
  port: System.get_env("DB_PORT") || "5432",
  pool: Ecto.Adapters.SQL.Sandbox

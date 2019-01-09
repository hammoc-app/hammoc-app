use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hammoc, HammocWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
#   -> https://gist.github.com/cohawk/df29c1c54abd858dd19d8327e862822a
config :hammoc, Hammoc.Repo,
  adapter: Ecto.Adapters.Postgres,
  port: 26257,
  username: "root",
  database: "hammoc_test",
  hostname: "localhost",
  pool: EctoReplaySandbox

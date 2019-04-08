# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :hammoc,
  ecto_repos: [Hammoc.Repo],
  generators: [binary_id: true]

config :hammoc, Hammoc.Repo, migration_primary_key: [type: :binary_id]

# Configures the endpoint
config :hammoc, HammocWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QsWL9jJw00QsH/6UnZiCXzDgha0JFsoeE6qi43aN967m8lUsM4O5B4U7G6tPTDVy",
  render_errors: [view: HammocWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Hammoc.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Parse .pug template files using expug
#   -> https://hexdocs.pm/expug/syntax.html
config :phoenix, :template_engines, pug: PhoenixExpug.Engine

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Handles encryption
#  -> set encryption key via `HAMMOC_VAULT_KEY` and `HAMMOC_PBKDF2_SECRET` in Base64 encoding
#  -> to generate each in `iex`: `64 |> :crypto.strong_rand_bytes() |> Base.encode64()`
config :hammoc, Hammoc.Vault,
  ciphers: [
    default:
      {Cloak.Ciphers.AES.GCM,
       tag: "AES.GCM.V1", key: <<0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 6, 7>>}
  ]

config :hammoc, Hammoc.Ecto.Hashed.PBKDF2,
  algorithm: :sha256,
  iterations: 10_000,
  secret: "not-so-secret",
  size: 64

config :ueberauth, Ueberauth, providers: [twitter: {Ueberauth.Strategy.Twitter, []}]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

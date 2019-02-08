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

# Twitter configuration

config :extwitter, :oauth, [
  consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
  consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
  access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
  access_token_secret: System.get_env("TWITTER_ACCESS_TOKEN_SECRET")
]
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

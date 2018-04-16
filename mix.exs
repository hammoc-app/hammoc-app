defmodule Hammoc.Mixfile do
  use Mix.Project

  def project do
    [
      app: :hammoc,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Hammoc.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # database
      # ========
      # workarounds for CockroachDB
      #  -> https://github.com/jumpn/postgrex
      #  -> https://github.com/jumpn/ecto_replay_sandbox
      #  -> https://gist.github.com/cohawk/df29c1c54abd858dd19d8327e862822a
      {:ecto, "~> 2.1", github: "arnodirlam/ecto", tag: "v2.2.10_cdb", override: true},
      {:postgrex, "~> 0.13", hex: :postgrex_cdb, override: true},
      {:ecto_replay_sandbox, "~> 1.0", only: :test},
      {:uuid, "~> 1.1.0"},

      # phoenix
      # =======
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:phoenix_expug, "~> 0.1.0"},
      {:cowboy, "~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end

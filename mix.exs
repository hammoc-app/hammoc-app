defmodule Hammoc.MixProject do
  use Mix.Project

  def project do
    [
      app: :hammoc,
      version: "0.0.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:ex_unit],
        flags: [:unmatched_returns, :error_handling, :race_conditions, :no_opaque]
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls.html": :test]
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
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},

      # Frontend
      # ========
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},
      {:scrivener_list, "~> 2.0"},
      {:scrivener_html, "~> 1.8"},

      # APIs
      # ========
      {:extwitter, "~> 0.9"},

      # Authentication
      # ==============
      {:ueberauth, "~> 0.6"},
      {:ueberauth_twitter, github: "hammoc-app/ueberauth_twitter"},

      # Data handling
      # =============
      {:gen_stage, "~> 0.14"},
      {:cloak_ecto, "~> 1.0.0-alpha.0"},
      {:pbkdf2, "~> 2.0"},

      # Language extensions
      # ===================
      {:typed_struct, "~> 0.1"},

      # dev & test
      # ==========
      {:mox, "~> 0.5", only: :test},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test, runtime: false},
      {:mix_test_watch, "~> 0.9", only: :dev, runtime: false},
      {:faker, "~> 0.12", only: [:dev, :test]},
      {:phoenix_integration, "~> 0.6", only: :test},

      # release & deploy
      # ================
      {:distillery, "~> 2.0"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
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
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end

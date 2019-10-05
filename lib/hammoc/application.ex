defmodule Hammoc.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # Twitter configuration
    ExTwitter.configure(
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
      access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
      access_token_secret: System.get_env("TWITTER_ACCESS_TOKEN_SECRET")
    )

    Application.put_env(:ueberauth, Ueberauth.Strategy.Twitter.OAuth,
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET")
    )

    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Hammoc.Repo,
      # Start the endpoint when the application starts
      HammocWeb.Endpoint,
      # Starts a worker by calling: Hammoc.Worker.start_link(arg)
      %{id: :systemd, start: {:systemd, :start_link, []}},
      Hammoc.Vault
      # {Hammoc.Worker, arg},
      # {Hammoc.Scraper.Twitter.Loader, "HillaryClinton"},
      # Hammoc.Scraper.Twitter.Collector
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hammoc.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HammocWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

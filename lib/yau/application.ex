defmodule Yau.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      YauWeb.Telemetry,
      Yau.Repo,
      {DNSCluster, query: Application.get_env(:yau, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Yau.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Yau.Finch},
      # Start a worker by calling: Yau.Worker.start_link(arg)
      # {Yau.Worker, arg},
      # Start to serve requests, typically the last entry
      YauWeb.Endpoint,
      Yau.Journeys,
      Yau.Vehicles
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Yau.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    YauWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

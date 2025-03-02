defmodule OrgChat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OrgChatWeb.Telemetry,
      OrgChat.Repo,
      {DNSCluster, query: Application.get_env(:org_chat, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: OrgChat.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: OrgChat.Finch},
      # Start a worker by calling: OrgChat.Worker.start_link(arg)
      # {OrgChat.Worker, arg},
      # Start to serve requests, typically the last entry
      OrgChatWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OrgChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OrgChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

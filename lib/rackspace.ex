defmodule Rackspace do
  use Application
  require Logger
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @impl true
  def start(_type, _args) do
    children = [
      {Rackspace.Config, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rackspace.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Rackspace do
  use Application
  require Logger
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Rackspace.Worker, [arg1, arg2, arg3])
    ]
    config = Application.get_env(:rackspace, :api)

    # TODO
    # Need to sanitize values before adding them to the config
    username = config[:username] || System.get_env("RS_USERNAME")
    password = config[:password] || System.get_env("RS_PASSWORD")
    api_key = config[:api_key] || System.get_env("RS_API_KEY")
    
    Rackspace.configure(
      username: username,
      password: password,
      api_key: api_key
    )

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rackspace.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec configure(Keyword.t) :: :ok
  defdelegate configure(auth), to: Rackspace.Config, as: :set

  @spec configure(:global | :process, Keyword.t) :: :ok
  defdelegate configure(scope, auth), to: Rackspace.Config, as: :set
end

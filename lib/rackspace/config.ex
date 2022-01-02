defmodule Rackspace.Config do
  require Logger

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, opts},
      type: :worker,
      restart: :permanent
    }
  end

  def start_link() do
    config = Application.get_env(:rackspace, :api)
    username = config[:username] || System.get_env("RS_USERNAME")
    password = config[:password] || System.get_env("RS_PASSWORD")
    api_key = config[:api_key] || System.get_env("RS_API_KEY")

    Agent.start_link(
      fn ->
        %{
          username: username,
          password: password,
          api_key: api_key
        }
      end,
      name: __MODULE__
    )
  end

  @doc """
  Get Auth configuration values.
  """
  def get do
    Agent.get(__MODULE__, & &1)
  end

  @doc """
  Set Auth configuration values.
  """
  def set(value) do
    Agent.update(__MODULE__, &Map.merge(&1, value))
  end

  @doc """
  Get Auth configuration values in tuple format.
  """
  def get_tuples do
    case Rackspace.Config.get() do
      nil -> []
      tuples -> tuples |> Enum.map(fn {k, v} -> {k, to_charlist(v)} end)
    end
  end
end

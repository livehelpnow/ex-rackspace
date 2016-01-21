defmodule Rackspace.Config do
  require Logger
  def current_scope do
    if Process.get(:_rackspace_auth, nil), do: :process, else: :global
  end

  @doc """
  Get Auth configuration values.
  """
  def get, do: get(current_scope)
  def get(:global) do
    Application.get_env(:rackspace, :auth, nil)
  end
  def get(:process), do: Process.get(:_rackspace_auth, nil)

  @doc """
  Set Auth configuration values.
  """
  def set(value), do: set(current_scope, value)
  def set(:global, value) do
    Application.put_env(:rackspace, :auth, value)
  end
  def set(:process, value) do
    Process.put(:_rackspace_auth, value)
    :ok
  end

  @doc """
  Get Auth configuration values in tuple format.
  """
  def get_tuples do
    case Rackspace.Config.get do
      nil -> []
      tuples -> tuples |> Enum.map(fn({k, v}) -> {k, to_char_list(v)} end)
    end
  end
end

defmodule Rackspace.Api.CloudFiles.Container do
  defstruct name: nil, count: 0, bytes: 0

  alias Rackspace.Api
  @mod :cloudFiles

  def list(opts \\ []) do
    url = "#{Api.base_url(@mod, opts)}?format=json"
    resp = Api.request(:get, url, opts[:headers])
    case Api.validate_resp(resp) do
      {:ok, resp} ->
        resp
          |> Map.get(:body)
          |> Poison.decode!(keys: :atoms)
          |> Enum.reduce([], fn(container, acc)->
            [%__MODULE__{
              name: container.name,
              count: container.count,
              bytes: container.bytes
            } | acc]
          end)
      {_, error} -> error
    end
  end

  def put(container, opts \\ []) do
    url = "#{Api.base_url(@mod, opts)}/#{container}?format=json"
    resp = Api.request(:get, url, opts[:headers])
    case Api.validate_resp(resp) do
      {:ok, _} -> {:ok, :created}
      {_, error} -> error
    end
  end

  def delete(container, opts \\ []) do
    url = "#{Api.base_url(@mod, opts)}/#{container}?format=json"
    resp = Api.request(:get, url, opts[:headers])
    case Api.validate_resp(resp) do
      {:ok, _} -> {:ok, :deleted}
      {_, error} -> error
    end
  end
end

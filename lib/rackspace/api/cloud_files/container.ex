defmodule Rackspace.Api.CloudFiles.Container do
  defstruct name: nil, count: 0, bytes: 0

  use Rackspace.Api.Base
  alias Rackspace.Api.CloudFiles
  require Logger

  def list(opts \\ []) do
    get_auth()
    region = opts[:region] || Application.get_env(:rackspace, :default_region)
    url = "#{CloudFiles.base_url(region)}?format=json"
    resp = request_get(url, opts)
    case validate_resp(resp) do
      {:ok, _} ->
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
    get_auth()
    region = opts[:region] || Application.get_env(:rackspace, :default_region)
    url = "#{CloudFiles.base_url(region)}/#{container}?format=json"
    resp = request_put(url, <<>>, opts)
    case validate_resp(resp) do
      {:ok, _} -> {:ok, :created}
      {_, error} -> error
    end
  end

  def delete(container, opts \\ []) do
    get_auth()
    region = opts[:region] || Application.get_env(:rackspace, :default_region)
    url = "#{CloudFiles.base_url(region)}/#{container}?format=json"
    resp = request_delete(url, opts)
    case validate_resp(resp) do
      {:ok, _} -> {:ok, :deleted}
      {_, error} -> error
    end
  end

end

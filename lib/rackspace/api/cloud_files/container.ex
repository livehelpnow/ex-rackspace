defmodule Rackspace.Api.CloudFiles.Container do
  @moduledoc """
  CRUD operations over Rackspace Cloud Files Containers
  """
  defstruct name: nil, count: 0, bytes: 0

  use Rackspace.Api.Base, service: :cloud_files
  require Logger

  @doc """
  Returns the list of cloud containers in rackspace.

  Containeres are like folders, there is option to pass which region you want to use `[region: ord]`

  ## Examples
    alias Rackspace.Api.CloudFiles.Container
    require Logger

    case Container.list([region: "ORD"]) do
      list when is_list(list) ->
        Logger.info(inspect(list))
      %Rackspace.Error{code: 403, message: message} ->
        Logger.error(message)
        # this should not happen but left for example purposes
      %Rackspace.Error{code: 0, message: message} ->
        Logger.error(message)
        # probably network error or timout
        # .. error
      end
    end
  """
  def list(opts \\ []) do
    get_auth()
    region = opts[:region] || Application.get_env(:rackspace, :default_region)
    url = "#{base_url(region)}?format=json"
    resp = request_get(url, opts)

    case validate_resp(resp) do
      {:ok, data} ->
        data
        |> Map.get(:body)
        |> Jason.decode!(keys: :atoms)
        |> Enum.reduce([], fn container, acc ->
          [
            %__MODULE__{
              name: container.name,
              count: container.count,
              bytes: container.bytes
            }
            | acc
          ]
        end)

      {:error, error} ->
        error
    end
  end

  def put(container, opts \\ []) do
    get_auth()
    region = opts[:region] || Application.get_env(:rackspace, :default_region)
    url = "#{base_url(region)}/#{container}?format=json"
    resp = request_put(url, <<>>, opts)

    case validate_resp(resp) do
      {:ok, _} -> {:ok, :created}
      {:error, error} -> error
    end
  end

  def delete(container, opts \\ []) do
    get_auth()
    region = opts[:region] || Application.get_env(:rackspace, :default_region)
    url = "#{base_url(region)}/#{container}?format=json"
    resp = request_delete(url, opts)

    case validate_resp(resp) do
      {:ok, _} -> {:ok, :deleted}
      {:error, error} -> error
    end
  end
end

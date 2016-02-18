defmodule Rackspace.Api.CloudFiles.Object do
  defstruct [
    container: nil,
    bytes: 0,
    content_type: nil,
    content_encoding: nil,
    hash: nil,
    last_modified: nil,
    name: nil,
    metadata: [],
    data: <<>>
  ]

  require Logger
  use Rackspace.Api.Base
  alias Rackspace.Api.CloudFiles

  def list(container, opts \\ []) do
    get_auth
    region = opts[:region] || Application.get_env(:rackspace, :default_region)
    url = "#{CloudFiles.base_url(region)}/#{container}?format=json"
    resp = request_get(url, opts)
    case validate_resp(resp) do
      {:ok, _} ->
        resp
          |> Map.get(:body)
          |> Poison.decode!(keys: :atoms)
          |> Enum.reduce([], fn(object, acc)->
            [%__MODULE__{
              container: container,
              name: object.name,
              bytes: object.bytes,
              content_type: object.content_type
            } | acc]
          end)
      {_, error} -> error
    end
  end

  def get(container, object, opts \\ []) do
    get_auth
    region = opts[:region] || Application.get_env(:rackspace, :default_region)
    url = "#{CloudFiles.base_url(region)}/#{container}/#{object}?format=json"
    resp = request_get(url, opts)
    case validate_resp(resp) do
      {:ok, _} ->
        Logger.debug "Response Headers: #{inspect resp.headers}"
        metadata = Enum.filter(resp.headers, fn({k,v}) ->
          to_string(k)
            |> String.starts_with?("X-Object-Meta")
        end)
        {bytes, _} = Integer.parse(resp.headers[:"Content-Length"])

        %__MODULE__{
          container: container,
          name: object,
          data: resp.body,
          hash: resp.headers[:Etag],
          content_type: resp.headers[:"Content-Type"],
          content_encoding: resp.headers[:"Content-Encoding"],
          bytes: bytes,
          last_modified: resp.headers[:"Last-Modified"],
          metadata: metadata
        }
      {_, error} -> error
    end
  end

  def put(container, name, data, opts \\ []) do
    get_auth
    region = opts[:region] || Application.get_env(:rackspace, :default_region)
    url = "#{CloudFiles.base_url(region)}/#{container}/#{name}?format=json"
    resp = request_put(url, data, opts)
    case validate_resp(resp) do
      {:ok, _} -> {:ok, :created}
      {_, error} -> error
    end
  end

  def delete(container, object, opts \\ []) do
    get_auth
    region = opts[:region] || Application.get_env(:rackspace, :default_region)
    url = "#{CloudFiles.base_url(region)}/#{container}/#{object}?format=json"
    resp = request_delete(url)
    case validate_resp(resp) do
      {:ok, _} -> {:ok, :deleted}
      {_, error} -> error
    end
  end

  def delete_multiple_objects(container, objects, opts \\ []) do
    get_auth
    region = opts[:region] || Application.get_env(:rackspace, :default_region)
    body = objects |> Enum.map(fn(obj) -> URI.encode("#{container}/#{obj}") end) |> Enum.join("\n")
    url = "#{CloudFiles.base_url(region)}?format=json&bulk-delete=true"
    resp = request_delete(url, [], %{content_type: "text/plain"}, body)
  end
end

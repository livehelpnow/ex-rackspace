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

  @mod :cloudFiles

  require Logger
  alias Rackspace.Api

  def list(container, opts \\ []) do
    url = "#{Api.base_url(@mod, opts)}/#{container}?format=json"
    resp = Api.request(:get, url, opts[:headers])
    case Api.validate_resp(resp) do
      {:ok, resp} ->
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

  # def get(container, object, opts \\ []) do
  #   url = "#{Api.base_url(@mod, opts)}/#{container}/#{object}?format=json"
  #   resp = Api.request(:get, url, opts[:headers])
  #   case Api.validate_resp(resp) do
  #     {:ok, resp} ->
  #       Logger.debug "Response Headers: #{inspect resp.headers}"
  #       metadata = Enum.filter(resp.headers, fn({k,v}) ->
  #         to_string(k)
  #           |> String.starts_with?("X-Object-Meta")
  #       end)
  #       {bytes, _} = Integer.parse(resp.headers[:"Content-Length"])
  #
  #       %__MODULE__{
  #         container: container,
  #         name: object,
  #         data: resp.body,
  #         hash: resp.headers[:Etag],
  #         content_type: resp.headers[:"Content-Type"],
  #         content_encoding: resp.headers[:"Content-Encoding"],
  #         bytes: bytes,
  #         last_modified: resp.headers[:"Last-Modified"],
  #         metadata: metadata
  #       }
  #     {_, error} -> error
  #   end
  # end
  #
  def put(container, name, data, opts \\ []) do
    url = "#{Api.base_url(@mod, opts)}/#{container}/#{name}?format=json"
    resp = Api.request(:put, url, opts[:headers], data)
    case Api.validate_resp(resp) do
      {:ok, _} -> {:ok, :created}
      {_, error} -> error
    end
  end
  #
  # def delete(container, object, opts \\ []) do
  #   get_auth
  #   region = opts[:region] || Application.get_env(:rackspace, :default_region)
  #   url = "#{CloudFiles.base_url(region)}/#{container}/#{object}?format=json"
  #   resp = request_delete(url)
  #   case validate_resp(resp) do
  #     {:ok, _} -> {:ok, :deleted}
  #     {_, error} -> error
  #   end
  # end
end

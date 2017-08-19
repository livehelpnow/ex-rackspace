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
  use Rackspace.Api.Base, service: :cloud_files

  def list(container, opts \\ []) do
    get_auth()
    region = opts[:region] || Application.get_env(:rackspace, :default_region)
    url = "#{base_url(region)}/#{container}?format=json"
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
      {:error, error} -> error
    end
  end

  def get(container, object, opts \\ []) do
    get_auth()
    region = opts[:region] || Application.get_env(:rackspace, :default_region)
    url = "#{base_url(region)}/#{container}/#{object}?format=json"
    resp = request_get(url, opts)
    case validate_resp(resp) do
      {:ok, _} ->
        headers = resp.headers.hdrs
        metadata = Enum.filter(headers, fn({k,_v}) ->
          to_string(k)
            |> String.starts_with?("x-container-meta")
        end)
        {bytes, _} = Integer.parse(headers["content-length"])

        %__MODULE__{
          container: container,
          name: object,
          data: resp.body,
          hash: headers["etag"],
          content_type: headers["content-type"],
          content_encoding: headers["content-encoding"],
          bytes: bytes,
          last_modified: headers["last-modified"],
          metadata: metadata
        }
      {:error, error} -> error
    end
  end

  def put(container, name, data, opts \\ []) do
    get_auth()
    region = opts[:region] || Application.get_env(:rackspace, :default_region)
    url = "#{base_url(region)}/#{container}/#{name}?format=json"
    resp = request_put(url, data, opts)
    case validate_resp(resp) do
      {:ok, _} -> {:ok, :created}
      {:error, error} -> error
    end
  end

  def delete(container, object, opts \\ []) do
    get_auth()
    region = opts[:region] || Application.get_env(:rackspace, :default_region)
    url = "#{base_url(region)}/#{container}/#{object}?format=json"
    resp = request_delete(url)
    case validate_resp(resp) do
      {:ok, _} -> {:ok, :deleted}
      {:error, error} -> error
    end
  end

  def delete_multiple_objects(container, objects, opts \\ []) do
    get_auth()
    region = opts[:region] || Application.get_env(:rackspace, :default_region)
    body = objects |> Enum.map(fn(obj) -> URI.encode("#{container}/#{obj}") end) |> Enum.join("\n")
    url = "#{base_url(region)}?format=json&bulk-delete=true"
    resp = request_delete(url, [], %{content_type: "text/plain"}, body)
    case validate_resp(resp) do
      {:ok, _} ->
        case Poison.decode(resp.body) do
          {:ok, body} -> {:ok, body["Number Deleted"]}
          {_, error} -> {:error, error}
        end
      {:error, error} -> error
    end
  end
end

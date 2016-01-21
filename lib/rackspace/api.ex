defmodule Rackspace.Api do
  @timeout 5000

  require Logger

  def request(method, url, headers, body \\ "") do
    default_headers = [
      "User-Agent": "ex-rackspace",
      "X-Auth-Token": auth_token,
      "Content-Type": "application/json"
    ]

    headers = Keyword.merge(default_headers, headers || [])
    Logger.debug "Url: #{inspect url}"
    Logger.debug "Body: #{inspect body}"
    Logger.debug "Headers: #{inspect headers}"

    HTTPoison.request(
      method,
      url,
      body,
      headers,
      timeout: @timeout
    )
  end

  def auth_token do
    auth = Rackspace.Config.get
    if auth[:token] == nil do
      Rackspace.Api.Identity.request
    end
    Rackspace.Config.get
    |> Map.get(:token)
  end

  def validate_resp({:ok, resp}) do
    cond do
      resp.status_code >= 200 and
      resp.status_code <= 300 ->
        {:ok, resp}
      true ->
        {:error, %Rackspace.Error{code: resp.status_code, message: resp.body}}
    end
  end

  def base_url(mod, opts) do
    config = Application.get_env(:rackspace, :api)
    region = opts[:region] || config[:region]
    case Application.get_env(:rackspace, mod) do
      nil ->
        Rackspace.Identity.request
        base_url(mod, opts)
      list ->
        url(region, list)
    end
  end

  def url(nil, _) do
    raise "You must specify a region"
  end
  def url(region, list) do
    Logger.debug "Checking Region: #{inspect region}"
    Logger.debug "List: #{inspect list}"
    region_url = list
    |> Keyword.get(:endpoints, [])
    |> Enum.find(fn(endpoint) ->
      endpoint_region = Map.get(endpoint, "region", "")
      String.downcase(region) == String.downcase(endpoint_region)
    end)
    |> Map.get("publicURL")
  end
end

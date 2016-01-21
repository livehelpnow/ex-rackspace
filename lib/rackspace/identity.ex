defmodule Rackspace.Identity do
  require Logger

  def request do
    auth = Rackspace.Config.get
      |> validate_auth
    json =
    case auth[:password] do
      nil ->
        %{"auth" =>
          %{"RAX-KSKEY:apiKeyCredentials" =>
            %{"username" => auth[:username], "apiKey" => auth[:api_key]}
          }
        }
      passwd ->
        %{"auth" =>
          %{"passwordCredentials" =>
            %{"username" => to_string(auth[:username]), "password" => passwd}
          }
        }
    end |> Poison.encode!
    Logger.debug "Json: #{inspect json}"
    headers = [
      "User-Agent": "ex-rackspace",
      "Content-Type": "application/json"
    ]
    HTTPoison.request(
      :post,
      "https://identity.api.rackspacecloud.com/v2.0/tokens",
      json,
      headers,
      timeout: 5000
    )
    |> validate_resp
  end

  def validate_resp({:ok, resp}) do
    body = resp
    |> Map.get(:body)
    |> Poison.decode!

    Logger.debug "Resp: #{inspect resp}"

    %{token: body["access"]["token"]["id"], expires_at: body["access"]["token"]["expires"]}
    |> Rackspace.Config.set

    account = [id: body["access"]["user"]["id"], name: body["access"]["user"]["name"]]
    Application.put_env(:rackspace, :account, account)
    Application.put_env(:rackspace, :default_region, body["access"]["user"]["RAX-AUTH:defaultRegion"])

    Enum.each(body["access"]["serviceCatalog"], fn(%{"name" => name} = service) ->
      Application.put_env(:rackspace, String.to_atom(name), Enum.reduce(service, [], fn({k, v}, acc) ->
        Keyword.put(acc, String.to_atom(k), v)
      end))
    end)
  end

  def validate_resp({_, error}), do: error

  def validate_auth(auth) do
    Logger.debug "Auth: #{inspect auth}"
    if auth[:username] == nil and
       (auth[:password] == nil or auth[:api_key] == nil) do
      raise """
        Rackspace config missing password or api key.
      """
    else
      auth
    end
  end
end

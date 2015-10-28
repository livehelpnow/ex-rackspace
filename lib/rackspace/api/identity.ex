defmodule Rackspace.Api.Identity do
  use Rackspace.Api.Base

  alias Rackspace.Config
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

    HTTPotion.start
    resp =
    "https://identity.api.rackspacecloud.com/v2.0/tokens"
      |> HTTPotion.post([
        body: json,
        headers: ["User-Agent": "rackspace-ex", "Content-Type": "application/json"]
      ])
    case validate_resp(resp) do
      {:ok, resp} ->
        body = resp
          |> Map.get(:body)
          |> Poison.decode!
        Logger.debug "Resp: #{inspect resp}"
        %{token: body["access"]["token"]["id"], expires_at: body["access"]["token"]["expires"]}
          |> Config.set
        account = [id: body["access"]["user"]["id"], name: body["access"]["user"]["name"]]
        Application.put_env(:rackspace, :account, account)
        Application.put_env(:rackspace, :default_region, body["access"]["user"]["RAX-AUTH:defaultRegion"])
        Enum.each(body["access"]["serviceCatalog"], fn(%{"name" => name} = service) ->
          Application.put_env(:rackspace, String.to_atom(name), Enum.reduce(service, [], fn({k, v}, acc) ->
            Keyword.put(acc, String.to_atom(k), v)
          end))
        end)
      {_, error} -> error
    end
  end

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

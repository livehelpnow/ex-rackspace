defmodule Rackspace.Api.Identity do
  use Rackspace.Api.Base, service: :cloud_auth_service

  alias Rackspace.Config
  require Logger

  def request do
    auth =
      Rackspace.Config.get()
      |> validate_auth

    json =
      case auth[:password] do
        nil ->
          %{
            "auth" => %{
              "RAX-KSKEY:apiKeyCredentials" => %{
                "username" => auth[:username],
                "apiKey" => auth[:api_key]
              }
            }
          }

        passwd ->
          %{
            "auth" => %{
              "passwordCredentials" => %{
                "username" => to_string(auth[:username]),
                "password" => passwd
              }
            }
          }
      end
      |> Jason.encode!()

    safe_json = Regex.replace(~r/"apiKey":"[^"]+"/, json, ~s("api_key": "RETRACTED"))
    Logger.debug("Json: #{inspect(safe_json)}")

    resp =
      "https://identity.api.rackspacecloud.com/v2.0/tokens"
      |> HTTPoison.post(
        json,
        "User-Agent": "rackspace-ex",
        "Content-Type": "application/json"
      )

    case validate_resp(resp) do
      {:ok, resp} ->
        body =
          resp
          |> Map.get(:body)
          |> Jason.decode!()

        Logger.debug("Resp: #{inspect(body)}")

        %{token: body["access"]["token"]["id"], expires_at: body["access"]["token"]["expires"]}
        |> Config.set()

        account = [id: body["access"]["user"]["id"], name: body["access"]["user"]["name"]]
        Application.put_env(:rackspace, :account, account)

        Application.put_env(
          :rackspace,
          :default_region,
          body["access"]["user"]["RAX-AUTH:defaultRegion"]
        )

        Enum.each(body["access"]["serviceCatalog"], fn %{"name" => name} = service ->
          Application.put_env(
            :rackspace,
            String.to_atom(Macro.underscore(name)),
            Enum.reduce(service, [], fn {k, v}, acc ->
              Keyword.put(acc, String.to_atom(k), v)
            end)
          )
        end)

        {:ok}

      {:error, error} ->
        {:error, error}
    end
  end

  def validate_auth(auth) do
    auth_safe = %{auth | api_key: "RETRACTED", password: "RETRACTED"}
    Logger.debug("Auth: #{inspect(auth_safe)}")

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

defmodule Rackspace.Api.Base do
  defmacro __using__(_opts) do
    quote do
      defp get_auth do
        auth = Rackspace.Config.get
        if auth[:token] == nil do
          Rackspace.Api.Identity.request
        end
        Rackspace.Config.get
      end

      defp validate_resp(resp) do
        cond do
          resp.status_code >= 200 and
          resp.status_code <= 300 ->
            {:ok, resp}
          true ->
            {:error, %Rackspace.Error{code: resp.status_code, message: resp.body}}
        end
      end

      defp request_get(url, params \\ []) do
        auth = get_auth
        url
          |> query_params(params)
          |> HTTPotion.get([headers: [
            "X-Auth-Token": auth[:token],
            "Content-Type": "application/json"
          ]])
      end

      defp request_put(url, body \\ <<>>, params \\ []) do
        auth = get_auth
        url
          |> query_params(params)
          |> HTTPotion.put([headers: [
            "X-Auth-Token": auth[:token]
          ], body: body])
      end

      defp request_delete(url, params \\ []) do
        auth = get_auth
        url
          |> query_params(params)
          |> HTTPotion.delete([headers: [
            "X-Auth-Token": auth[:token]
          ]])
      end

      defp query_params(url, params) do
        Enum.reduce(params, url, fn({k,v}, acc) ->  
          acc = "#{acc}&#{k}=#{v}"
        end)
      end
    end
  end
end
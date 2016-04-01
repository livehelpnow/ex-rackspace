defmodule Rackspace.Api.Base do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      require Logger

      defp expired? do
        if expire_date = Rackspace.Config.get[:expires_at] do
          Timex.before?(Timex.parse!(expire_date, "{ISO:Extended}"), Timex.DateTime.now)
        else
          false
        end
      end

      defp get_auth do
        auth = Rackspace.Config.get
        if auth[:token] == nil || expired? do
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

      defp request_get(url, params \\ [], opts \\ []) do
        auth = get_auth
        timeout = Application.get_env(:rackspace, :timeout) || 5_000

        url
          |> query_params(params)
          |> HTTPotion.get([headers: [
            "X-Auth-Token": auth[:token],
            "Content-Type": "application/json"
          ], timeout: timeout])
      end

      defp request_put(url, body \\ <<>>, params \\ [], opts \\ []) do
        auth = get_auth
        timeout = Application.get_env(:rackspace, :timeout) || 5_000

        url
          |> query_params(params)
          |> HTTPotion.put([headers: [
            "X-Auth-Token": auth[:token]
          ], body: body, timeout: timeout])
      end

      defp request_delete(url, params \\ [], opts \\ []) do
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

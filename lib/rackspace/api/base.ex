defmodule Rackspace.Api.Base do
  @moduledoc ~S"""
  Base module for service access.

  It should be used as base module for any concrete implementation of specific service.
  When used, in module you need to specify which service it is implmenting so some function may now
  how to read configuration received from rackspace. For instance, base_url(region) is using service keyword
  to find what is the base url for such service

  Possible services are:
  - `:autoscale`
  - `:cloud_servers_open_stack`
  - `:cloud_backup`
  - `:cloud_big_data`
  - `:cloud_block_storage`
  - `:cloud_databases`
  - `:cloud_dns`
  - `:cloud_feeds`
  - `:cloud_files`
  - `:cloud_files_cdn`
  - `:cloud_images`
  - `:cloud_load_balancers`
  - `:cloud_metrics`
  - `:cloud_monitoring`
  - `:cloud_networks`
  - `:cloud_orchestration`
  - `:cloud_queues`
  - `:cloud_sites`
  - `:rack_cdn`
  - `:rackconnect`

  ## Examples
    ```elixir
    defmodule Rackspace.Api.CloudFiles.Container
      defstruct name: nil, count: 0, bytes: 0
      use Rackspace.Api.Base, service: :cloud_files

      def list([region: region]) do
        url = "#{base_url(region)}?format=json"
        # ... use url in HTTPotion
      end
    end
    ```
  """
  defmacro __using__(service: service) do
    quote do
      import unquote(__MODULE__)
      require Logger

      defp base_url(region, opts \\ []) do
        Application.get_env(:rackspace, service)
        |> Keyword.get(:endpoints)
        |> Enum.find(fn ep -> String.downcase(ep["region"]) == String.downcase(region) end)
        |> Map.get("publicURL")
      end

      defp expired? do
        if expire_date = Rackspace.Config.get()[:expires_at] do
          {:ok, date, _} =DateTime.from_iso8601(expire_date)
          DateTime.compare(date, DateTime.utc_now()) == :lt
        else
          false
        end
      end

      defp get_auth do
        auth = Rackspace.Config.get()

        if auth[:token] == nil || expired?() do
          case Rackspace.Api.Identity.request() do
            {:ok} ->
              Rackspace.Config.get()

            {:error, error} ->
              raise "fail to authenticate"
          end
        else
          Rackspace.Config.get()
        end
      end

      defp validate_resp(resp) do
        case resp do
          {:ok, %Req.Response{status: status_code} = data}
          when status_code >= 200 and status_code <= 300 ->
            {:ok, data}

          {:ok, %Req.Response{status: status_code, body: message}} ->
            # validation and conflict errors in case 4XX errors and 500 should have empty body
            {:error, %Rackspace.Error{code: status_code, message: message}}

          {:error, exception} ->
            {:error, %Rackspace.Error{code: 0, message: Exception.message(exception)}}
        end
      end

      defp request_get(url, params \\ [], opts \\ []) do
        case get_auth() do
          %{token: token} when is_nil(token) == false ->
            timeout = Application.get_env(:rackspace, :timeout) || 5_000
            timeout = Keyword.get(opts, :timout, timeout)

            url = url |> query_params(params)

            Req.get(url,
              headers: %{"x-auth-token" => token, "content-type" => "application/json"},
              retry: false,
              receive_timeout: timeout
            )

          _ ->
            %Rackspace.Error{code: 0, message: "token_expired"}
        end
      end

      defp request_post(url, body \\ <<>>, params \\ [], opts \\ []) do
        case get_auth() do
          %{token: token} when is_nil(token) == false ->
            timeout = Application.get_env(:rackspace, :timeout) || 5_000
            timeout = Keyword.get(opts, :timout, timeout)

            url = url |> query_params(params)

            Req.post(url,
              body: body,
              headers: %{"x-auth-token" => token},
              retry: false,
              receive_timeout: timeout
            )

          _ ->
            %Rackspace.Error{code: 0, message: "token_expired"}
        end
      end

      defp request_put(url, body \\ <<>>, params \\ [], opts \\ []) do
        case get_auth() do
          %{token: token} when is_nil(token) == false ->
            timeout = Application.get_env(:rackspace, :timeout) || 5_000
            timeout = Keyword.get(opts, :timout, timeout)
            expire_at = Keyword.get(params, :expire_at, 63_072_000)

            url = url |> query_params(params)

            Req.put(url,
              headers: %{"x-auth-token" => token, "x-delete-after" => expire_at, "Content-Length" => opts[:length], "Content-Type" => opts[:content_type]},
              retry: false,
              receive_timeout: timeout
            )

          _ ->
            %Rackspace.Error{code: 0, message: "token_expired"}
        end
      end

      defp request_delete(url, params \\ [], opts \\ [], body \\ <<>>) do
        case get_auth() do
          %{token: token} when is_nil(token) == false ->
            content_type = opts[:content_type] || "application/json"
            accept = opts[:accept] || "application/json"
            timeout = Application.get_env(:rackspace, :timeout) || 5_000
            timeout = Keyword.get(opts, :timout, timeout)

            url = url |> query_params(params)

            Req.delete(url,
              body: body,
              headers: %{"x-auth-token" => token, "accept" => accept, "content-type" => content_type},
              retry: false,
              receive_timeout: timeout
            )

          _ ->
            %Rackspace.Error{code: 0, message: "token_expired"}
        end
      end

      defp query_params(url, params) do
        Enum.reduce(params, url, fn {k, v}, acc ->
          acc = "#{acc}&#{k}=#{v}"
        end)
      end
    end
  end
end

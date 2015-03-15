defmodule Rackspace.Api.CloudFiles do

  def base_url(region, opts \\ []) do
    region = Application.get_env(:rackspace, :cloudFiles)
      |> Keyword.get(:endpoints)
      |> Enum.find(fn(ep) ->  
        String.downcase(ep["region"]) == String.downcase(region)
      end)
      |> Map.get("publicURL")
  end
end
defmodule Rackspace.Endpoint do
  @path_separator "/"

  @spec build_url(binary | [binary], Keyword.t) :: binary
  def build_url(path, opts \\ [])
  def build_url(path, opts) when is_list(path) do
    List.flatten(path)
      |> Enum.join(@path_separator)
      |> build_url(opts)
  end
  def build_url(path, []), do: path
  def build_url(path, opts) when is_binary(path) do
    path <> "?" <> URI.encode_query(opts)
  end

end

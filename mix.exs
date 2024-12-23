defmodule Rackspace.Mixfile do
  use Mix.Project

  def project do
    [
      app: :rackspace,
      version: "0.1.0",
      elixir: "~> 1.3",
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {Rackspace, []}
    ]
  end

  defp deps do
    [
      {:ibrowse, "~> 4.2"},
      {:req, "~> 0.4"},
      {:timex, "~> 3.0"},
      {:jason, "~> 1.0"},
      {:excoveralls, "~> 0.7", only: :test}
    ]
  end
end

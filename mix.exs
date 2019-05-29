defmodule Rackspace.Mixfile do
  use Mix.Project

  def project do
    [app: :rackspace,
     version: "0.1.0",
     elixir: "~> 1.3",
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :httpotion, :timex],
     mod: {Rackspace, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:ibrowse, "~> 4.2"},
      {:httpotion, "~> 3.0"},
      {:timex, "~> 3.0"},
      {:poison, "~> 3.0"},
      {:excoveralls, "~> 0.7", only: :test}
    ]
  end
end

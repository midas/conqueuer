defmodule Conqueuer.Mixfile do
  use Mix.Project

  def project do
    [app: :conqueuer,
     version: "0.5.0",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     preferred_cli_env: [espec: :test],
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: package]
  end

  defp package do
    [
      description: "An Elixir in memory work queue.",
      files: [
        "lib",
        "mix.exs",
        "README.md",
        "LICENSE*"
      ],
      maintainers: ["Jason Harrelson"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/midas/conqueuer"
      }
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:espec, "~> 0.8", only: :test},
      {:ex_doc, "~> 0.10", only: :dev},
        {:earmark, ">= 0.0.0", only: :dev},
      {:inflex, "~> 1.5"},
      {:poolboy, "~> 1.5"}
    ]
  end
end

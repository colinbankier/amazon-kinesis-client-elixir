defmodule Kclex.Mixfile do
  use Mix.Project

  def project do
    [app: :kclex,
     version: "0.0.1",
     elixir: "~> 1.0",
     description: "An amazon kinesis KCL client for elixir.",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :porcelain]]
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
      {:exjsx, "~> 3.1.0"},
      {:inflex, "~> 1.0.0"},
      {:radpath, "~> 0.0.5"},
      {:tempfile, github: "lowks/tempfile"},
      {:timex, "~> 0.13.4"},
      {:porcelain, "~> 2.0"},
    ]
  end
end

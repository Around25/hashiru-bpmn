defmodule Bpmn.Mixfile do
  use Mix.Project

  @version "0.1.0-dev"

  def project do
    [
      app: :bpmn,
      version: @version,
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      package: package(),
      deps: deps(),
      description: "A BPMN engine for elixir",

      # Docs
      name: "Hashiru BPMN",
      source_url: "https://github.com/around25/hashiru-bpmn",
      homepage_url: "https://github.com/around25/hashiru-bpmn",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      docs: docs()
    ]
  end

  defp package do
    [
      name: "bpmn",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Cosmin Harangus"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/around25/hashiru-bpmn"}
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {Bpmn.Application, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:credo, "~> 0.8.8", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.16", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.7.4", only: [:dev, :test], runtime: false},
      {:poison, "~> 3.1"}
    ]
  end

  defp docs do
    [
      main: "readme", # The main page in the docs
      extras: ["README.md", "DEVELOPER.md", "CONTRIBUTING.md", "CODE_OF_CONDUCT.md"]
    ]
  end
end

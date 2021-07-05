defmodule Azure.MixProject do
  use Mix.Project

  @version "0.2.1"
  @repo_url "https://github.com/joeapearson/elixir-azure"

  def project do
    [
      app: :azure,
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:credo, "~> 1.5.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ex_machina, only: [:dev, :test]},
      {:hackney, "~> 1.17.4"},
      {:jason, "~> 1.2.2", optional: true},
      {:named_args, "~> 0.1.1"},
      {:poison, ">= 1.0.0", optional: true},
      {:sweet_xml, "~> 0.7.0"},
      {:tesla, "~> 1.4.1"},
      {:timex, "~> 3.7.5"},
      {:xml_builder, "~> 2.2.0"}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      description: "Azure storage",
      links: %{"GitHub" => @repo_url},
      licenses: ["MIT"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md"
      ],
      authors: [
        "almirsarajcic",
        "bettyblocks",
        "chgeuer",
        "joeapearson"
      ],
      source_ref: "v#{@version}",
      source_url: @repo_url,
      api_reference: false
    ]
  end

  # Configures dialyzer (static analysis tool for Elixir / Erlang).
  #
  # The `dialyzer.plt` file takes a long time to generate first time round, so we store it in a
  # custom location where it can then be easily cached during CI.
  defp dialyzer do
    [
      plt_add_apps: [:eex, :mix, :jason],
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end
end

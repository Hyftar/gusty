defmodule Gusty.MixProject do
  use Mix.Project

  def project do
    [
      app: :gusty,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: %{
        description: "Lightweight Tailwind CSS class merging for Elixir. Zero dependencies, no compile-time overhead.",
        licenses: ["GPL-3.0-or-later"],
        links: %{"GitHub" => "https://github.com/hyftar/gust"}
      }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end

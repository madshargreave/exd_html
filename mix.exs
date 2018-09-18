defmodule ExdHTML.MixProject do
  use Mix.Project

  def project do
    [
      app: :exd_html,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:exd, "~> 0.1.2"},
      {:floki, "~> 0.20.0"},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end

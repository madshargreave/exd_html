defmodule ExdHTML.MixProject do
  use Mix.Project

  def project do
    [
      app: :exd_html,
      version: "0.1.0",
      elixir: "~> 1.7",
      description: description(),
      package: package(),
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
      {:exd, "~> 0.1.29"},
      {:floki, "~> 0.20.0"},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description() do
    "UDFs for parsing HTML strings"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "exd_plugin_html",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/madshargreave/exd_plugin_html"}
    ]
  end

end

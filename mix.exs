defmodule Jsend.MixProject do
  use Mix.Project

  def project do
    [
      app: :jsend,
      version: "0.1.1",
      elixir: "~> 1.10",
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
      {:phoenix, "> 0.0.0"},
      {:jason, "> 0.0.0"}
    ]
  end
end

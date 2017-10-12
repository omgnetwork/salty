defmodule Salty.Mixfile do
  use Mix.Project

  def project do
    [
      app: :salty,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:enacl, git: "https://github.com/jlouis/enacl.git", tag: "0.16.0"},
      {:cloak, "~> 0.3.3", only: [:dev, :test]},
    ]
  end
end

defmodule Salty.Mixfile do
  use Mix.Project

  def project do
    [
      app: :salty,
      version: "0.2.0-pre.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      source_url: "https://github.com/omisego/salty"
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
      {:cloak, "~> 0.7.0-alpha", only: [:dev, :test]}
    ]
  end

  defp description do
    "Elixir wrapper for enacl and libsodium."
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/omisego/salty"},
      maintainers: ["Thibault Denizet", "Unnawut Leepaisalsuwanna"]
    ]
  end
end

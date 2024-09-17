defmodule UeberauthCAS.Mixfile do
  use Mix.Project

  @version "1.1.1"
  @url     "https://github.com/marceldegraaf/ueberauth_cas"

  def project do
    [
      app: :ueberauth_cas,
      version: @version,
      elixir: "~> 1.7",
      name: "Ueberauth CAS strategy",
      package: package(),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      source_url: @url,
      homepage_url: @url,
      description: "An Ueberauth strategy for CAS authentication.",
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
    ]
  end

  def application do
    [
      applications: [:logger, :ueberauth, :httpoison]
    ]
  end

  defp deps do
    [
      {:ueberauth, "~> 0.10"},
      {:httpoison, "~> 2.2"},
      {:sweet_xml, "~> 0.7"},
      {:excoveralls, "~> 0.8", only: :test},
      {:inch_ex, "~> 2.0", only: :docs},
      {:earmark, "~> 1.4", only: :dev},
      {:ex_doc, "~> 0.34", only: :dev},
      {:mock, "~> 0.3", only: :test},
      {:jason, "~> 1.4"},
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Marcel de Graaf"],
      licenses: ["MIT"],
      links: %{"GitHub": @url}
    ]
  end
end

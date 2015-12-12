defmodule CIDR.Mixfile do
  use Mix.Project

  @version "0.4.0"

  def project do
    [
      app: :cidr,
      elixir: ">= 1.0.2",
      deps: [
        {:credo,       "~> 0.2",  only: [:dev, :test]},
        {:earmark,     "~> 0.1",  only: [:dev, :docs]},
        {:ex_doc,      "~> 0.11", only: [:dev, :docs]},
        {:excoveralls, "~> 0.4",  only: [:dev, :test]},
        {:inch_ex,                only: :docs}
      ],
      description: "Classless Inter-Domain Routing (CIDR) for Elixir",
      docs: [
        main: "CIDR",
        source_ref: "v#{@version}",
        source_url: "https://github.com/c-rack/cidr-elixir"
      ],
      package: package,
      test_coverage: [tool: ExCoveralls],
      version: @version
    ]
  end

  def application do
    [applications: []]
  end

  defp package do
    %{
      maintainers: [
        "Constantin Rack",
        "Laurens Duijvesteijn"
      ],
      licenses: ["MIT License"],
      links: %{
        "Changelog" => "https://github.com/c-rack/cidr-elixir/blob/master/CHANGELOG.md",
        "Docs" => "https://hexdocs.pm/cidr",
        "GitHub" => "https://github.com/c-rack/cidr-elixir"
      }
    }
  end

end

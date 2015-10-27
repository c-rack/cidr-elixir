defmodule CIDR.Mixfile do
  use Mix.Project

  @version "0.3.0"

  def project do
    [
      app: :cidr,
      elixir: ">= 1.0.2",
      deps: [
        {:earmark, "~> 0.1",  only: [:dev, :docs]},
        {:ex_doc,  "~> 0.10", only: [:dev, :docs]},
      ],
      description: "Classless Inter-Domain Routing (CIDR) for Elixir",
      docs: [
        main: "CIDR",
        source_ref: "v#{@version}",
        source_url: "https://github.com/c-rack/cidr-elixir"
      ],
      package: package,
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

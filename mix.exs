defmodule CIDR.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cidr,
      version: "0.3.0",
      elixir: ">= 1.0.2",
      source_url: "https://github.com/c-rack/cidr-elixir",
      deps: [],
      description: "Classless Inter-Domain Routing (CIDR) for Elixir",
      package: package
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
      links: %{"Github" => "https://github.com/c-rack/cidr-elixir"}
    }
  end

end

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule CIDR.Mixfile do
  use Mix.Project

  @version "1.1.0"

  def project do
    [
      app: :cidr,
      elixir: ">= 1.3.0",
      deps: [
        {:credo,       "~> 0.4",  only: [:dev, :test]},
        {:earmark,     "~> 1.0",  only: [:dev, :docs]},
        {:ex_doc,      "~> 0.13", only: [:dev, :docs]},
        {:excoveralls, "~> 0.5",  only: [:dev, :test]},
        {:inch_ex,     "~> 0.5",  only: :docs}
      ],
      description: "Classless Inter-Domain Routing (CIDR) for Elixir",
      docs: [
        main: "CIDR",
        source_ref: "v#{@version}",
        source_url: "https://github.com/c-rack/cidr-elixir"
      ],
      package: package(),
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
      licenses: ["Mozilla Public License 2.0"],
      links: %{
        "Changelog" => "https://github.com/c-rack/cidr-elixir/blob/master/CHANGELOG.md",
        "GitHub" => "https://github.com/c-rack/cidr-elixir"
      }
    }
  end

end

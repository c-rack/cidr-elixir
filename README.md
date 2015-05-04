# CIDR, a [Classless Inter-Domain Routing](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) library for [Elixir](http://www.elixir-lang.org/)

[![Hex.pm Version](http://img.shields.io/hexpm/v/cidr.svg)](https://hex.pm/packages/cidr)


## Setup

To use this library in your project, edit your mix.exs file and add cidr as a dependency:

```elixir
defp deps do
  [
    { :cidr, "~> 0.2.0" }
  ]
end
```

## Usage

Parse an IP address / CIDR:
```elixir
iex(1)> cidr = "1.2.3.4/24" |> CIDR.parse
%CIDR{ip: {1, 2, 3, 4}, mask: 24}
```

Match against a CIDR:
```elixir
iex(2)> cidr |> CIDR.match({1,2,3,100})
true
iex(3)> cidr |> CIDR.match({1,2,4,1})
false
```

## License

[MIT License](LICENSE).

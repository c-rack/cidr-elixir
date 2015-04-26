# CIDR-Elixir

[Classless Inter-Domain Routing (CIDR)](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) for [Elixir](http://www.elixir-lang.org/)

## Setup

To use this library in your project, edit your mix.exs file and add cidr as a dependency:

```elixir
defp deps do
  [
    { :cidr, "~> 0.1.0" }
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

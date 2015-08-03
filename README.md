# CIDR, a [Classless Inter-Domain Routing](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) library for [Elixir](http://www.elixir-lang.org/)

[![Hex.pm Version](http://img.shields.io/hexpm/v/cidr.svg)](https://hex.pm/packages/cidr)
[![Build Status](https://travis-ci.org/c-rack/cidr-elixir.png?branch=master)](https://travis-ci.org/c-rack/cidr-elixir)

## Setup

To use this library in your project, edit your `mix.exs` file and add cidr as a dependency:

```elixir
defp deps do
  [
    {:cidr, ">= 0.2.0"}
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

## Contribution Process

This project uses the [C4.1 process](http://rfc.zeromq.org/spec:22) for all code changes.

> "Everyone, without distinction or discrimination, SHALL have an equal right to become a Contributor under the
terms of this contract."

### tl;dr

1. Check for [open issues](https://github.com/c-rack/cidr-elixir/issues) or [open a new issue](https://github.com/c-rack/cidr-elixir/issues/new) to start a discussion around a feature idea or a bug
2. Fork the [cidr-elixir repository on Github](https://github.com/c-rack/cidr-elixir) to start making your changes
3. Write a test which shows that the bug was fixed or that the feature works as expected
4. Send a pull request and wait for it to be merged

## License

[MIT License](LICENSE).

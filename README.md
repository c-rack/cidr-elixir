# CIDR

[![Hex.pm Version](http://img.shields.io/hexpm/v/cidr.svg)](https://hex.pm/packages/cidr)
[![Build Status](https://travis-ci.org/c-rack/cidr-elixir.png?branch=master)](https://travis-ci.org/c-rack/cidr-elixir)

[Classless Inter-Domain Routing](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)
(CIDR) utilities for [Elixir](http://www.elixir-lang.org/)

## Setup

To use this library in your project, edit your `mix.exs` file and add `:cidr`
as a dependency:

```elixir
defp deps do
  [
    {:cidr, ">= 0.3.0"}
  ]
end
```

## Usage

When you pass in an IP address string into `CIDR.parse`, you get a `%CIDR{}`
struct back. This contains the start and end addresses as Erlang IP tuples,
the amount of hosts the range covers and the mask.

```elixir
iex(1)> cidr = "1.2.3.4/24" |> CIDR.parse
%CIDR{start: {1, 2, 3, 0}, end: {1, 2, 3, 255}, hosts: 256, mask: 24}
```

You can query the struct for all of its fields:

```elixir
iex(2)> cidr.start
{1, 2, 3, 0}
iex(3)> cidr.hosts
256
```

And use it to see if other IP addresses fall in the same range:

```elixir
iex(4)> cidr |> CIDR.match({1,2,3,100})
true
iex(5)> cidr |> CIDR.match({1,2,4,1})
false
```

The match function also supports IP strings:

```elixir
iex(6)> cidr |> CIDR.match("1.2.3.100")
true
iex(7)> cidr |> CIDR.match("1.2.4.1")
false
```

## Contribution Process

This project uses the [C4.1 process](http://rfc.zeromq.org/spec:22) for all
code changes.

> "Everyone, without distinction or discrimination, SHALL have an equal right
> to become a Contributor under the terms of this contract."

### TL;DR

1. Check for [open issues](https://github.com/c-rack/cidr-elixir/issues) or
[open a new issue](https://github.com/c-rack/cidr-elixir/issues/new) to start
a discussion around a feature idea or a bug.
2. Fork the [cidr-elixir repository on Github](https://github.com/c-rack/cidr-elixir)
to start making your changes.
3. Write a test which shows that the bug was fixed or that the feature works as
expected
4. Send a pull request and wait for it to be merged

## License

[MIT License](LICENSE).

# CIDR

[![Downloads](https://img.shields.io/hexpm/dt/cidr.svg)](https://hex.pm/packages/cidr)
[![Hex.pm Version](http://img.shields.io/hexpm/v/cidr.svg)](https://hex.pm/packages/cidr)
[![Build Status](https://travis-ci.org/c-rack/cidr-elixir.png?branch=master)](https://travis-ci.org/c-rack/cidr-elixir)
[![Coverage Status](https://coveralls.io/repos/c-rack/cidr-elixir/badge.svg?branch=&service=github)](https://coveralls.io/github/c-rack/cidr-elixir?branch=)
[![Inline docs](http://inch-ci.org/github/c-rack/cidr-elixir.svg?branch=master)](http://inch-ci.org/github/c-rack/cidr-elixir)

[Classless Inter-Domain Routing](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)
(CIDR) utilities for [Elixir](http://www.elixir-lang.org/)

## Setup

To use this library, just add `:cidr` as a dependency to your `mix.exs` file:

```elixir
defp deps do
  [
    {:cidr, ">= 1.1.0"}
  ]
end
```

## Usage

Passing an IP address string into `CIDR.parse` returns a `%CIDR{}` struct.
It contains the first and the last address of the range as Erlang IP tuples,
the amount of hosts the range covers and the network mask.

```elixir
iex(1)> cidr = "1.2.3.4/24" |> CIDR.parse
%CIDR{first: {1, 2, 3, 0}, last: {1, 2, 3, 255}, hosts: 256, mask: 24}
```

You can query the struct for all of its fields:

```elixir
iex(2)> cidr.first
{1, 2, 3, 0}
iex(3)> cidr.hosts
256
```

And use it to see if other IP addresses fall in the same range:

```elixir
iex(4)> cidr |> CIDR.match!({1,2,3,100})
true
iex(5)> cidr |> CIDR.match!({1,2,4,1})
false
```

The `match!/2` function also supports IP strings:

```elixir
iex(6)> cidr |> CIDR.match!("1.2.3.100")
true
iex(7)> cidr |> CIDR.match!("1.2.4.1")
false
```

Please note that `match!/2` throws an `ArgumentError` when you pass in a value
that does not represent a valid IP address or when you try to match an IPv4
address with an IPv6 range and vice-versa.
We also provide `match/2`, a non-throwing version that returns tagged tuples:

```elixir
iex(8)> cidr |> CIDR.match("1.2.3.100")
{:ok, true}
iex(9)> cidr |> CIDR.match("1.2.4.1")
{:ok, false}
iex(10)> cidr |> CIDR.match("1.2.3.1000")
{:error, "Tuple is not a valid IP address."}
```

## Contribution

See [Collective Code Construction Contract (C4)](http://rfc.zeromq.org/spec:42/C4/)

## License

[Mozilla Public License 2.0](LICENSE)


# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule CIDR do
  use Bitwise

  @moduledoc """
  Classless Inter-Domain Routing (CIDR)
  """

  defstruct first: nil, last: nil, mask: nil, hosts: nil

  defimpl String.Chars, for: CIDR do

    @doc """
    Prints cidr objectes in human readable format

    IPv4: 1.1.1.0/24
    IPv6: 2001::/64
    """
    def to_string(cidr), do: "#{:inet.ntoa(cidr.first)}/#{cidr.mask}"

  end

  @doc """
  Check whether the argument is a CIDR value.

  ## Examples

      iex> CIDR.is_cidr?("192.168.1.254/32")
      true
  """
  def is_cidr?(cidr) when is_map(cidr) do
    cidr.__struct__ == CIDR
  end
  def is_cidr?(string) when is_bitstring(string) do
    string
    |> parse
    |> is_cidr?
  end
  def is_cidr?(_), do: false

  @doc """
  Checks if an IP address is in the provided CIDR.

  Returns `{:ok, true}` if the address is in the CIDR range, `{:ok, false}` if
  it's not, and `{:error, reason}` if the second argument isn't a valid IP
  address.
  """
  def match(cidr, address) when is_binary(address) do
    case parse_address(address) do
      {:ok,    ip}     -> match(cidr, ip)
      {:error, reason} -> {:error, reason}
    end
  end
  def match(%CIDR{first: {a, b, c, d}, last: {e, f, g, h}}, address = {i, j, k, l}) do
    if is_ipv4(address) do
      result =
        i in a..e and
        j in b..f and
        k in c..g and
        l in d..h
      {:ok, result}
    else
      {:error, "Tuple is not a valid IP address"}
    end
  end
  def match(%CIDR{first: {a, b, c, d, e, f, g, h}, last: {i, j, k, l, m, n, o, p}},
            address = {q, r, s, t, u, v, w, x}) do
    if is_ipv6(address) do
      result =
        q in a..i and
        r in b..j and
        s in c..k and
        t in d..l and
        u in e..m and
        v in f..n and
        w in g..o and
        x in h..p
      {:ok, result}
    else
      {:error, "Tuple is not a valid IP address"}
    end
  end
  def match(_cidr, _address),
    do: {:error, "Argument must be a binary or IP tuple of the same protocol"}

  @doc """
  Throwing version of match/2, raises `ArgumentError` on error.
  """
  def match!(cidr, address) do
    case match(cidr, address) do
      {:ok,    result} -> result
      {:error, reason} -> raise ArgumentError, message: reason
    end
  end

  @doc """
  Returns a stream of all hosts in the range


  ## Examples

         iex> CIDR.parse("192.168.0.0/31") |> CIDR.hosts |> Enum.map(fn(x) -> x end)
         [{192, 168, 0, 0}, {192, 168, 0, 1}]

  """
  def hosts(%CIDR{first: {_, _, _, _}} = cidr) do
    t = tuple2number(cidr.first, (32 - cidr.mask))
    Stream.map(0..(cidr.hosts - 1), fn(x) -> number2tuple(t + x, :ipv4) end)
  end
  def hosts(%CIDR{first: {_, _, _, _, _, _, _, _}} = cidr) do
    t = tuple2number(cidr.first, (128 - cidr.mask))
    Stream.map(0..(cidr.hosts - 1), fn(x) -> number2tuple(t + x, :ipv6) end)
  end

  @doc """
  Checks if two cidr objects are equal


  ### Examples

       iex> d = CIDR.parse("10.0.0.0/24")
       %CIDR{first: {10, 0, 0, 0}, hosts: 256, last: {10, 0, 0, 255}, mask: 24}
       iex> c = CIDR.parse("10.0.0.0/24")
       %CIDR{first: {10, 0, 0, 0}, hosts: 256, last: {10, 0, 0, 255}, mask: 24}
       iex(21)> CIDR.equal?(d, c)
       true

  """
  def equal?(a, b) do
    a.first == b.first and
    a.last == b.last
  end


  @doc """
  Checks if a is a subnet of b
  """
  def subnet?(%CIDR{mask: mask_a}, %CIDR{mask: mask_b}) when mask_a < mask_b do
    false
  end
  def subnet?(a, b) do
    (tuple2number(a.first, 0) >= tuple2number(b.first, 0)) and
    (tuple2number(a.last, 0) <= tuple2number(b.last, 0))
  end

  @doc """
  Checks if a is a supernet of b
  """
  def supernet?(%CIDR{mask: mask_a}, %CIDR{mask: mask_b}) when mask_a > mask_b do
    false
  end
  def supernet?(a, b) do
    tuple2number(a.first, 0) <= tuple2number(b.first, 0) and
    tuple2number(a.last, 0) >= tuple2number(b.last, 0)
  end
  @doc """
  Splits an existing cidr into smaller blocks


  ### Examples

         iex> CIDR.parse("192.168.0.0/24") |> CIDR.split(25) |> Enum.map(&(&1))
         [%CIDR{first: {192, 168, 0, 0}, hosts: 128, last: {192, 168, 0, 127}, mask: 25},
          %CIDR{first: {192, 168, 0, 128}, hosts: 128, last: {192, 168, 0, 255}, mask: 25}]

  """
  def split(%CIDR{mask: mask}, new_mask) when mask > new_mask do
    {:error, "New mask must be larger than existing cidr"}
  end
  def split(%CIDR{first: {_, _, _, _}}=cidr, new_mask) do
    x = tuple2number(cidr.first, 32 - cidr.mask)
    split(x, new_mask, cidr.mask, :ipv4)
  end
  def split(%CIDR{first: {_, _, _, _, _, _, _, _}}=cidr, new_mask) do
    x = tuple2number(cidr.first, 128 - cidr.mask)
    split(x, new_mask, cidr.mask, :ipv6)
  end
  defp split(start, new_mask, old_mask, afi) do
    n = :math.pow(2, (new_mask - old_mask))- 1 |> round
    step = num_hosts(afi, new_mask)
    Stream.map(0..n, fn(x) ->
      offset = start + (step) * x
      first = number2tuple(offset, afi)
      last = number2tuple((offset + (step - 1)), afi)
      %CIDR{first: first, last: last, mask: new_mask, hosts: step}
    end)
  end

  @doc """
  Parses a bitstring into a CIDR struct
  """
  def parse(string) when string |> is_bitstring do
    [address | mask]  = string |> String.split("/")
    case parse_address(address) do
      {:ok, address}   -> parse(address, mask)
      {:error, reason} -> {:error, reason}
    end
  end
  # Only bitstrings can be parsed
  def parse(_other) do
    {:error, "Not a bitstring"}
  end
  # We got a simple IP address without mask
  defp parse(address, []) when tuple_size(address) == 4 do
    create(address, address, 32, num_hosts(:ipv4, 32))
  end
  defp parse(address, []) when tuple_size(address) == 8 do
    create(address, address, 128, num_hosts(:ipv6, 128))
  end
  # We got a mask and need to convert it to integer
  defp parse(address, [mask]) do
    parse(address, mask |> int)
  end
  # Validate that mask is valid
  defp parse(address, mask) when tuple_size(address) == 4 and not mask in 0..32 do
    {:error, "Invalid mask #{mask}"}
  end
  defp parse(address, mask) when tuple_size(address) == 8 and not mask in 0..128 do
    {:error, "Invalid mask #{mask}"}
  end
  # Everything is fine
  defp parse(address, mask) when tuple_size(address) == 4 do
    parse(address, mask, :ipv4)
  end
  defp parse(address, mask) when tuple_size(address) == 8 do
    parse(address, mask, :ipv6)
  end
  defp parse(address, mask, version) do
    first = range_address(version, address, mask, false)
    last  = range_address(version, address, mask, true)
    create(first, last, mask, num_hosts(version, mask))
  end

  defp parse_address(address) do
    address |> String.to_char_list |> :inet.parse_address
  end

  defp create(first, last, mask, hosts) do
    %CIDR{first: first, last: last, mask: mask, hosts: hosts}
  end

  defp num_hosts(:ipv4, mask), do: 1 <<< (32 - mask)
  defp num_hosts(:ipv6, mask), do: 1 <<< (128 - mask)

  defp range_address(:ipv4, tuple, mask, is_last) do
    s = (32 - mask)
    x = tuple2number(tuple, s)
    x = if is_last, do: x ||| ((1 <<< s) - 1), else: x
    x |> number2tuple(:ipv4)
  end
  defp range_address(:ipv6, tuple, mask, is_last) do
    s = (128 - mask)
    x = tuple2number(tuple, s)
    x = if is_last, do: x ||| ((1 <<< s) - 1), else: x
    x |> number2tuple(:ipv6)
  end

  def number2tuple(n, afi) do
    case afi do
      :ipv6 -> number2list(n, 0, 16, 8, 0xFFFF) |> List.to_tuple
      :ipv4 -> number2list(n, 0, 8, 4, 0xFF) |> List.to_tuple
    end
  end
  def number2list(_, _, _, 0, _), do: []
  def number2list(x, s, d, i, m) do
    number2list(x, s + d, d, i - 1, m) ++ [(x >>> s) &&& m]
  end

  def tuple2number({a, b, c, d}, s) do
    (((a <<< 24) ||| (b <<< 16) ||| (c <<< 8) ||| d) >>> s) <<< s
  end
  def tuple2number({a, b, c, d, e, f, g, h}, s) do
    (((a <<< 112) ||| (b <<< 96) ||| (c <<< 80) ||| (d <<< 64)
    ||| (e <<< 48) ||| (f <<< 32) ||| (g <<< 16) ||| h) >>> s) <<< s
  end

  defp is_ipv4({_, _, _, _} = tuple), do: is_ipvx(tuple, 0..255)
  defp is_ipv4(_), do: false

  defp is_ipv6({_, _, _, _, _, _, _, _} = tuple), do: is_ipvx(tuple, 0..65_535)
  defp is_ipv6(_), do: false

  defp is_ipvx(tuple, range) do
    tuple
    |> Tuple.to_list
    |> Enum.all?(&(&1 in range))
  end

  defp int(x) do
    case x |> Integer.parse do
      :error -> -1
      {a, _} -> a
    end
  end

end

defmodule CIDR do
  use Bitwise

  @moduledoc """
  Classless Inter-Domain Routing (CIDR)
  """

  defstruct start: nil, end: nil, mask: nil, hosts: nil

  @doc """
  Check whether the argument is a CIDR value.

  ## Examples

      iex> CIDR.is_cidr?(%CIDR{ip: {192, 168, 1, 254}, mask: 32})
      true

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
  """
  def match(cidr, address) when is_binary(address) do
    ip = parse_address(address)
    match(cidr, ip)
  end
  def match(%CIDR{start: {a, b, c, d}, end: {e, f, g, h}}, {i, j, k, l}) do
    i in a..e and
    j in b..f and
    k in c..g and
    l in d..h
  end
  def match(%CIDR{start: {a, b, c, d, e, f, g, h}, end: {i, j, k, l, m, n, o, p}}, {q, r, s, t, u, v, w, x}) do
    q in a..i and
    r in b..j and
    s in c..k and
    t in d..l and
    u in e..m and
    v in f..n and
    w in g..o and
    x in h..p
  end
  def match(_address, _mask), do: false

  @doc """
  Parses a bitstring into a CIDR struct
  """
  def parse(string) when string |> is_bitstring do
    [address | mask]  = string |> String.split("/")
    ip_address = parse_address(address)

    case ip_address do
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
    create(min(address, mask), max(address, mask), 32, hosts(:ipv4, mask))
  end
  defp parse(address, []) when tuple_size(address) == 8 do
    create(min(address, mask), max(address, mask), 128, hosts(:ipv4, mask))
  end
  # We got a mask and need to convert it to integer
  defp parse(address, [mask]) do
    parse(address, mask |> int)
  end
  # Validate that mask is valid
  defp parse(address, mask) when
      tuple_size(address) == 4 and
      (mask < 0) or (mask > 32) do
    {:error, "Invalid mask #{mask}"}
  end
  defp parse(address, mask) when
      tuple_size(address) 8 and
      (mask < 0) or (mask > 128) do
    {:error, "Invalid mask #{mask}"}
  end
  # Everything is fine
  defp parse(address, mask) when tuple_size(address) == 4 do
    create(min(address, mask), max(address, mask), mask, hosts(:ipv4, mask))
  end
  defp parse(address, mask) when tuple_size(address) == 6 do
    create(min(address, mask), max(address, mask), mask, hosts(:ipv6, mask))
  end

  defp parse_address(address) do
    ip_address = address |> String.to_char_list |> :inet.parse_address
  end

  defp create(start, end, mask, hosts) do
    %CIDR{
      start: start,
      end:   end,
      mask:  mask,
      hosts: hosts
    }
  end

  defp hosts(:ipv4, mask) do
    1 <<< (32 - mask)
  end
  defp hosts(:ipv6, mask) do
    1 <<< (128 - mask)
  end

  defp min({a, b, c, d}, mask) do
    s   = (32 - mask)
    x   = (((a <<< 24) ||| (b <<< 16) ||| (c <<< 8) ||| d) >>> s) <<< s
    a1  = ((x >>> 24) &&& 0xFF)
    b1  = ((x >>> 16) &&& 0xFF)
    c1  = ((x >>>  8) &&& 0xFF)
    d1  = ((x >>>  0) &&& 0xFF)
    { a1, b1, c1, d1 }
  end

  defp max({a, b, c, d}, mask) do
    s   = (32 - mask)
    x   = (((a <<< 24) ||| (b <<< 16) ||| (c <<< 8) ||| d) >>> s) <<< s
    y   = x ||| ((1 <<< s) - 1)
    a1  = ((y >>> 24) &&& 0xFF)
    b1  = ((y >>> 16) &&& 0xFF)
    c1  = ((y >>>  8) &&& 0xFF)
    d1  = ((y >>>  0) &&& 0xFF)
    { a1, b1, c1, d1 }
  end

  defp is_ipv6({a, b, c, d, e, f, g, h}) do
    a in 0..65535 and
    b in 0..65535 and
    c in 0..65535 and
    d in 0..65535 and
    e in 0..65535 and
    f in 0..65535 and
    g in 0..65535 and
    h in 0..65535
  end
  defp is_ipv6(_), do: false

  defp is_ipv4({a, b, c, d}) do
    a in 0..255 and
    b in 0..255 and
    c in 0..255 and
    d in 0..255
  end
  defp is_ipv4(_), do: false

  defp mask_by_ip(address) do
    cond do
      is_ipv4(address) ->  32
      is_ipv6(address) -> 128
    end
  end

  defp int(x) do
    case x |> Integer.parse do
      :error  -> -1
      {a,_}   -> a
    end
  end

end

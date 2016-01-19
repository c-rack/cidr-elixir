defmodule CIDR do
  use Bitwise

  @moduledoc """
  Classless Inter-Domain Routing (CIDR)
  """

  defstruct first: nil, last: nil, start: nil, end: nil, mask: nil, hosts: nil

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

  Returns `{:ok, true}` if the address is in the CIDR range, {:ok, false} if
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
      {:error, "Tuple is not a valid IP address."}
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
      {:error, "Tuple is not a valid IP address."}
    end
  end
  def match(_cidr, _address),
    do: {:error, "Argument must be a binary or IP tuple of the same protocol."}

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
    %CIDR{
      first: first,
      last:  last,
      start: first, # Deprecated, use "first" instead
      end:   last,  # Deprecated, use "last" instead
      mask:  mask,
      hosts: hosts
    }
  end

  defp num_hosts(:ipv4, mask), do: 1 <<< (32 - mask)
  defp num_hosts(:ipv6, mask), do: 1 <<< (128 - mask)

  defp range_address(:ipv4, tuple, mask, is_last) do
    s = (32 - mask)
    x = tuple2number(tuple, s)
    if is_last, do: x = x ||| ((1 <<< s) - 1)
    a = ((x >>> 24) &&& 0xFF)
    b = ((x >>> 16) &&& 0xFF)
    c = ((x >>>  8) &&& 0xFF)
    d = ((x >>>  0) &&& 0xFF)
    {a, b, c, d}
  end
  defp range_address(:ipv6, tuple, mask, is_last) do
    s = (128 - mask)
    x = tuple2number(tuple, s)
    if is_last, do: x = x ||| ((1 <<< s) - 1)
    a = ((x >>> 112) &&& 0xFFFF)
    b = ((x >>>  96) &&& 0xFFFF)
    c = ((x >>>  80) &&& 0xFFFF)
    d = ((x >>>  64) &&& 0xFFFF)
    e = ((x >>>  48) &&& 0xFFFF)
    f = ((x >>>  32) &&& 0xFFFF)
    g = ((x >>>  16) &&& 0xFFFF)
    h = ((x >>>   0) &&& 0xFFFF)
    {a, b, c, d, e, f, g, h}
  end
  defp tuple2number({a, b, c, d}, s) do
    (((a <<< 24) ||| (b <<< 16) ||| (c <<< 8) ||| d) >>> s) <<< s
  end
  defp tuple2number({a, b, c, d, e, f, g, h}, s) do
    (((a <<< 112) ||| (b <<< 96) ||| (c <<< 80) ||| (d <<< 64)
    ||| (e <<< 48) ||| (f <<< 32) ||| (g <<< 16) ||| h) >>> s) <<< s
  end

  defp is_ipv4({_, _, _, _} = tuple), do: is_ipvx(tuple, 0..255)
  defp is_ipv4(_), do: false

  defp is_ipv6({_, _, _, _, _, _, _, _} = tuple), do: is_ipvx(tuple, 0..65535)
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

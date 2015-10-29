defmodule CIDR do
  use Bitwise

  @moduledoc """
  Classless Inter-Domain Routing (CIDR)
  """

  defstruct start: nil, end: nil, mask: nil, hosts: nil

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
  def match(%CIDR{start: {a, b, c, d}, end: {e, f, g, h}}, address = {i, j, k, l}) do
    if is_ipv4(address) do
      match =
        i in a..e and
        j in b..f and
        k in c..g and
        l in d..h
      {:ok, match}
    else
      {:error, "Tuple is not a valid IP address."}
    end
  end
  def match(%CIDR{start: {a, b, c, d, e, f, g, h}, end: {i, j, k, l, m, n, o, p}},
            address = {q, r, s, t, u, v, w, x}) do
    if is_ipv6(address) do
      match =
        q in a..i and
        r in b..j and
        s in c..k and
        t in d..l and
        u in e..m and
        v in f..n and
        w in g..o and
        x in h..p
      {:ok, match}
    else
      {:error, "Tuple is not a valid IP address."}
    end
  end
  def match(_address, _mask),
    do: {:error, "Argument must be a binary or IP tuple of the same protocol."}

  @doc """
  Throwing version of match/2, raises `ArgumentError` on error.
  """
  def match!(cidr, address) do
    case match(cidr, address) do
      {:ok,    match}  -> match
      {:error, reason} -> raise ArgumentError, message: reason
    end
  end

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
    create(address, address, 32, hosts(:ipv4, 32))
  end
  defp parse(address, []) when tuple_size(address) == 8 do
    create(address, address, 128, hosts(:ipv4, 128))
  end
  # We got a mask and need to convert it to integer
  defp parse(address, [mask]) do
    parse(address, mask |> int)
  end
  # Validate that mask is valid
  defp parse(address, mask) when
      tuple_size(address) == 4 and
      ((mask < 0) or (mask > 32)) do
    {:error, "Invalid mask #{mask}"}
  end
  defp parse(address, mask) when
      tuple_size(address) == 8 and
      ((mask < 0) or (mask > 128)) do
    {:error, "Invalid mask #{mask}"}
  end
  # Everything is fine
  defp parse(address, mask) when tuple_size(address) == 4 do
    create(start_address(address, mask), end_address(address, mask), mask, hosts(:ipv4, mask))
  end
  defp parse(address, mask) when tuple_size(address) == 8 do
    create(start_address(address, mask), end_address(address, mask), mask, hosts(:ipv6, mask))
  end

  defp parse_address(address) do
    address |> String.to_char_list |> :inet.parse_address
  end

  defp create(start, last, mask, hosts) do
    %CIDR{
      start: start,
      end:   last,
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

  defp start_address({a, b, c, d}, mask) do
    s   = (32 - mask)
    x   = (((a <<< 24) ||| (b <<< 16) ||| (c <<< 8) ||| d) >>> s) <<< s
    a1  = ((x >>> 24) &&& 0xFF)
    b1  = ((x >>> 16) &&& 0xFF)
    c1  = ((x >>>  8) &&& 0xFF)
    d1  = ((x >>>  0) &&& 0xFF)
    { a1, b1, c1, d1 }
  end
  defp start_address({a, b, c, d, e, f, g, h}, mask) do
    s   = (128 - mask)
    x   = (((a <<< 112) ||| (b <<< 96) ||| (c <<< 80) ||| (d <<< 64) ||| (e <<< 48) ||| (f <<< 32) ||| (g <<< 16) ||| h) >>> s) <<< s
    a1  = ((x >>> 112) &&& 0xFFFF)
    b1  = ((x >>>  96) &&& 0xFFFF)
    c1  = ((x >>>  80) &&& 0xFFFF)
    d1  = ((x >>>  64) &&& 0xFFFF)
    e1  = ((x >>>  48) &&& 0xFFFF)
    f1  = ((x >>>  32) &&& 0xFFFF)
    g1  = ((x >>>  16) &&& 0xFFFF)
    h1  = ((x >>>   0) &&& 0xFFFF)
    { a1, b1, c1, d1, e1, f1, g1, h1 }
  end

  defp end_address({a, b, c, d}, mask) do
    s   = (32 - mask)
    x   = (((a <<< 24) ||| (b <<< 16) ||| (c <<< 8) ||| d) >>> s) <<< s
    y   = x ||| ((1 <<< s) - 1)
    a1  = ((y >>> 24) &&& 0xFF)
    b1  = ((y >>> 16) &&& 0xFF)
    c1  = ((y >>>  8) &&& 0xFF)
    d1  = ((y >>>  0) &&& 0xFF)
    { a1, b1, c1, d1 }
  end
  defp end_address({a, b, c, d, e, f, g, h}, mask) do
    s   = (128 - mask)
    x   = (((a <<< 112) ||| (b <<< 96) ||| (c <<< 80) ||| (d <<< 64) ||| (e <<< 48) ||| (f <<< 32) ||| (g <<< 16) ||| h) >>> s) <<< s
    y   = x ||| ((1 <<< s) - 1)
    a1  = ((y >>> 112) &&& 0xFFFF)
    b1  = ((y >>>  96) &&& 0xFFFF)
    c1  = ((y >>>  80) &&& 0xFFFF)
    d1  = ((y >>>  64) &&& 0xFFFF)
    e1  = ((y >>>  48) &&& 0xFFFF)
    f1  = ((y >>>  32) &&& 0xFFFF)
    g1  = ((y >>>  16) &&& 0xFFFF)
    h1  = ((y >>>   0) &&& 0xFFFF)
    { a1, b1, c1, d1, e1, f1, g1, h1 }
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

  defp int(x) do
    case x |> Integer.parse do
      :error  -> -1
      {a,_}   -> a
    end
  end

end

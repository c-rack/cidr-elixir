defmodule CIDR do

  use Bitwise

  @moduledoc """
  Classless Inter-Domain Routing (CIDR)
  """

  defstruct ip: nil, mask: 32

  @doc """
  Set the `mask` of a `cidr` struct.

  ## Examples

      iex> CIDR.set_mask(%CIDR{ip: {192, 168, 1, 254}, mask: 32}, 16)
      %CIDR{ip: {192, 168, 1, 254}, mask: 16}
  """
  def set_mask(cidr, mask) when mask in 0..32 do
    %CIDR{ cidr | mask: mask }
  end

  def is_cidr(cidr) when is_map(cidr), do: cidr.__struct__ == CIDR
  def is_cidr(string) when is_bitstring(string), do: string |> parse |> is_cidr
  def is_cidr(_), do: false

  @doc """
  Checks if an IP address is in the provided CIDR.
  """
  def match(%CIDR{ip: {a, b, c, d}, mask: mask}, {e, f, g, h}) do
    cidr_value = (a <<< 24) ||| (b <<< 16) ||| (c <<< 8) ||| d
    ip_value   = (e <<< 24) ||| (f <<< 16) ||| (g <<< 8) ||| h
    (cidr_value >>> (32 - mask)) == (ip_value >>> (32 - mask))
  end
  def match(_address, _mask), do: false

  @doc """
  Parses a bitstring into a CIDR struct
  """
  def parse(string) when string |> is_bitstring do
    [address | mask]  = string |> String.split("/")
    ip_address = address |> String.to_char_list |> :inet.parse_address

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
  defp parse(address, []) do
    %CIDR{ip: address, mask: address |> mask_by_ip}
  end
  # We got a mask and need to convert it to integer
  defp parse(address, [mask]) do
    parse(address, mask |> int)
  end
  # Validate that mask in valid
  # TODO: Add IPv6 support
  defp parse(_address, mask) when (mask < 0) or (mask > 32) do
    {:error, "Invalid mask #{mask}"}
  end
  # Everything is fine
  defp parse(address, mask) do
    %CIDR{ip: address, mask: mask}
  end

  @doc """
  Returns the number of hosts covered.
  """
  def hosts(cidr) do
    1 <<< (mask_by_ip(cidr.ip) - cidr.mask)
  end

  @doc """
  Returns the lowest IP address covered.
  """
  def min(%CIDR{ ip: { a, b, c, d }, mask: mask }) do
    s   = (32 - mask)
    x   = (((a <<< 24) ||| (b <<< 16) ||| (c <<< 8) ||| d) >>> s) <<< s
    a1  = ((x >>> 24) &&& 0xFF)
    b1  = ((x >>> 16) &&& 0xFF)
    c1  = ((x >>>  8) &&& 0xFF)
    d1  = ((x >>>  0) &&& 0xFF)
    { a1, b1, c1, d1 }
  end

  @doc """
  Returns the highest IP address covered.
  """
  def max(%CIDR{ ip: { a, b, c, d }, mask: mask }) do
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

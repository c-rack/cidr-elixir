defmodule CIDR do

  use Bitwise

  @moduledoc """
  Classless Inter-Domain Routing (CIDR)
  """

  defstruct ip: nil, mask: 32

  def set_mask(cidr, mask) when mask in 0..32 do
    %CIDR{ cidr | mask: mask }
  end

  def is_cidr(cidr) when is_map(cidr), do: cidr.__struct__ == CIDR
  def is_cidr(string) when is_bitstring(string), do: string |> parse |> is_cidr
  def is_cidr(_), do: false

  @doc """
  Checks if an IP address is in the provided CIDR.
  """
  def match(%CIDR{ ip: { a0, b0, c0, d0 }, mask: mask } = _cidr, { a1, b1, c1, d1 } = _ip) do
    cidr_value = (a0 <<< 24) ||| (b0 <<< 16) ||| (c0 <<< 8) ||| d0
    ip_value = (a1 <<< 24) ||| (b1 <<< 16) ||| (c1 <<< 8) ||| d1
    (cidr_value >>> (32 - mask)) == (ip_value >>> (32 - mask))
  end
  def match(_address, _mask), do: false

  @doc "Parses a bitstring into a CIDR struct"
  def parse(string) when string |> is_bitstring do
    [address | mask]  = string |> String.split("/")
    ip_address = address |> String.to_char_list |> :inet.parse_address
    do_parse(ip_address, mask)
  end
  
  @doc "Only bitstrings can be parsed"
  def parse(_other) do
    {:error, "Not a bitstring"}
  end

  # :inet.parse_address failed, so we pass the reason to the caller
  defp do_parse({:error, reason}, _) do
    {:error, reason}
  end

  # We got a simple IP address without mask
  defp do_parse({:ok, address}, []) do
    %CIDR{ip: address, mask: address |> mask_by_ip}
  end
  # We got a mask and need to convert it to integer
  defp do_parse({:ok, address}, [mask]) do
    do_parse({:ok, address}, mask |> int)
  end
  # Validate that mask in valid
  # TODO: Add IPv6 support
  defp do_parse({:ok, _address}, mask) when (mask < 0) or (mask > 32) do
    {:error, "Invalid mask #{mask}"}
  end
  # Everything is fine
  defp do_parse({:ok, address}, mask) do
    %CIDR{ip: address, mask: mask}
  end
  # Otherwise, return error
  defp do_parse(ip_address, mask) do
    {:error, "Could not parse ip address #{inspect ip_address} and mask #{inspect mask}"}
  end

  @doc """
  Returns the number of hosts covered.
  """
  def hosts(cidr) do
    1 <<< (32 - cidr.mask)
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

  def is_ipv6({a, b, c, d, e, f, g, h}) when
    a in 0..65535 and
    b in 0..65535 and
    c in 0..65535 and
    d in 0..65535 and
    e in 0..65535 and
    f in 0..65535 and
    g in 0..65535 and
    h in 0..65535,  do: true
  def is_ipv6(_),   do: false

  def is_ipv4({a, b, c, d}) when
    a in 0..255 and
    b in 0..255 and
    c in 0..255 and
    d in 0..255,  do: true
  def is_ipv4(_), do: false

  def mask_by_ip(address) do
    cond do
      address |> is_ipv4  ->  32
      address |> is_ipv6  -> 128
      true                ->  -1
    end
  end

  defp int(x) do
    case x |> Integer.parse do
      :error  -> -1
      {a,_}   -> a
    end
  end

end

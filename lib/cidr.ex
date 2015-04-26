defmodule CIDR do

  use Bitwise

  @moduledoc """
  Classless Inter-Domain Routing (CIDR)
  """

  defstruct ip: { 0, 0, 0, 0 }, mask: 32

  def set_mask(cidr, mask) when mask in 0..32 do
    %CIDR{ cidr | mask: mask }
  end

  def is_cidr(cidr) when is_map(cidr) do
    cidr.__struct__ == CIDR
  end
  def is_cidr(string) when is_bitstring(string) do
    string |> to_cidr |> is_cidr
  end
  def is_cidr(_), do: false

  @doc """
  Checks if an IP address is in the provided CIDR.
  """
  def match(%CIDR{ ip: { a0, b0, c0, d0 }, mask: mask } = cidr, { a1, b1, c1, d1 } = ip) do
    cidr_value = (a0 <<< 24) ||| (b0 <<< 16) ||| (c0 <<< 8) ||| d0
    ip_value = (a1 <<< 24) ||| (b1 <<< 16) ||| (c1 <<< 8) ||| d1
    (cidr_value >>> (32 - mask)) == (ip_value >>> (32 - mask))
  end

  def to_cidr(string) when string |> is_bitstring do
    tokens = String.split(string, "/")
    if Enum.count(tokens) == 2 do
      result = 
        tokens
        |> List.first
        |> String.to_char_list
        |> :inet.parse_address
      is_ip_valid = 
        case result do
          { :ok, _ }    -> true
          { :error, _ } -> false
        end
      parsed_netmask =
        tokens
        |> List.last
        |> Integer.parse
      netmask =
        case parsed_netmask do
          { value, "" } -> value
          _             -> false
        end
      is_netmask_valid_range =
        if netmask do
          (netmask >= 0) and (netmask <= 32)
        else
          false
        end
      if is_ip_valid and is_netmask_valid_range do
        { :ok, ip } = result
        %CIDR{ ip: ip, mask: netmask }
      else
        false
      end
    else
      false
    end
  end
  def to_cidr(string), do: false
  
  defp regex_ip do
    ~r/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
  end
  
  def parse(string) do
    if string =~ regex_ip do
      to_cidr(string <> "/32")
    else
      to_cidr(string)
    end
  end

end

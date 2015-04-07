defmodule CIDR do

  @moduledoc """
  
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

  def to_cidr(string) do
	if Kernel.is_bitstring(string) do
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
	else
		false
	end
  end
	
end

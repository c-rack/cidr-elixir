# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule CIDRTest do
  use ExUnit.Case
  doctest CIDR

  test "127.0.0.1/32 is valid" do
    assert CIDR.is_cidr?("127.0.0.1/32") == true
  end

  test "127.0.0.1/64 is invalid" do
    assert CIDR.is_cidr?("127.0.0.1/64") == false
  end

  test "127.0.0.1/test is invalid" do
    assert CIDR.is_cidr?("127.0.0.1/test") == false
  end

  test "test/32 is invalid" do
    assert CIDR.is_cidr?("test/32") == false
  end

  test "127.0.0.1/32/64 is invalid" do
    assert CIDR.is_cidr?("127.0.0.1/32/64") == false
  end

  test "false is invalid" do
    assert CIDR.is_cidr?(false) == false
  end

  test "Parse 127.0.0.1" do
    assert "127.0.0.1" |> CIDR.parse |> CIDR.is_cidr?
  end

  test "Parse 127.0.0.1/24" do
    assert "127.0.0.1/24" |> CIDR.parse |> CIDR.is_cidr?
  end

  test "Do not parse ::1/256" do
    assert "::1/256" |> CIDR.parse == {:error, "Invalid mask 256"}
  end

  test "Start and end of IPv4 address range" do
    cidr = "127.0.0.1/24" |> CIDR.parse
    assert cidr.first == {127, 0, 0, 0}
    assert cidr.last  == {127, 0, 0, 255}
  end

  test "Start and end of IPv6 address range" do
    cidr = "::1/24" |> CIDR.parse
    assert cidr.first == {0, 0, 0, 0, 0, 0, 0, 0}
    assert cidr.last  == {0, 255, 65535, 65535, 65535, 65535, 65535, 65535}
  end

  test "Parse of single IP should return exactly 1 host" do
    cidr1 = CIDR.parse("127.0.0.1")
    assert cidr1.hosts == 1
    cidr2 = CIDR.parse("::1")
    assert cidr2.hosts == 1
  end

  # Match

  test "Match IPv6" do
    cidr = CIDR.parse("::1")
    assert CIDR.match(cidr, {1, 1, 1, 1, 1, 1, 1, 1}) == {:ok, false}
    assert CIDR.match(cidr, {0, 0, 0, 0, 0, 0, 0, 1}) == {:ok, true}
  end

  test "Match implied /32" do
    cidr = CIDR.parse("1.2.3.4")

    assert CIDR.match(cidr, {1, 1, 1, 1}) == {:ok, false}
    assert CIDR.match(cidr, {1, 2, 3, 3}) == {:ok, false}
    assert CIDR.match(cidr, {1, 2, 3, 4}) == {:ok, true}
    assert CIDR.match(cidr, {1, 2, 3, 5}) == {:ok, false}
    assert CIDR.match(cidr, {255, 255, 255, 255}) == {:ok, false}
  end

  test "Match /24" do
    cidr = CIDR.parse("1.2.3.4/24")

    assert CIDR.match(cidr, {1, 2, 3, 1}) == {:ok, true}
    assert CIDR.match(cidr, {1, 2, 3, 100}) == {:ok, true}
    assert CIDR.match(cidr, {1, 2, 3, 200}) == {:ok, true}
    assert CIDR.match(cidr, {1, 2, 3, 255}) == {:ok, true}
  end

  test "Match binaries" do
    cidr = CIDR.parse("1.2.3.4/24")

    assert CIDR.match(cidr, "1.2.3.9") == {:ok, true}
    assert CIDR.match(cidr, "1.2.3.254") == {:ok, true}
  end

  test "Match error handling" do
    cidr = CIDR.parse("1.2.3.4/24")

    assert CIDR.match(cidr, {1,2,3,257}) == {:error, "Tuple is not a valid IP address"}
    assert CIDR.match(cidr, {0, 0, 0, 0, 0, 0, 0, 100000}) == {:error, "Argument must be a binary or IP tuple of the same protocol"}
    assert CIDR.match(cidr, "This is not an IP") == {:error, :einval}
  end

  test "Match! error handling" do
    cidr = CIDR.parse("1.2.3.4/24")

    assert_raise ArgumentError, "Tuple is not a valid IP address", fn ->
      CIDR.match!(cidr, {1,2,3,257})
    end
    assert_raise ArgumentError, "Argument must be a binary or IP tuple of the same protocol", fn ->
      CIDR.match!(cidr, {0, 0, 0, 0, 0, 0, 0, 100000})
    end
    assert_raise ArgumentError, fn ->
      CIDR.match!(cidr, "This is not an IP")
    end
  end

  test "Match! without error" do
    cidr = CIDR.parse("1.2.3.4/24")
    assert CIDR.match!(cidr, {1,2,3,4}) == true
    assert CIDR.match!(cidr, {1,2,3,9}) == true
    assert CIDR.match!(cidr, {2,2,2,2}) == false
  end

  test "Split IPv4" do
    cidr_list = CIDR.parse("1.0.0.0/24") |> CIDR.split(28) |> Enum.map(&(&1))
    f = List.first cidr_list
    assert f.first == {1, 0, 0, 0}
    assert f.last == {1, 0, 0, 15}
    assert f.hosts == 16
    assert f.mask == 28
    f = List.last cidr_list
    assert f.first == {1, 0, 0, 240}
    assert f.last == {1, 0, 0, 255}
    assert f.hosts == 16
    assert f.mask == 28
    assert length(cidr_list) == 16
  end

  test "Split IPv6" do
    cidr_list = CIDR.parse("2001::/60") |> CIDR.split(64) |> Enum.map(&(&1))
    f = List.first cidr_list
    assert f.first == {8193, 0, 0, 0, 0, 0, 0, 0}
    assert f.last == {8193, 0, 0, 0, 65535, 65535, 65535, 65535}
    assert f.hosts == 18446744073709551616
    assert f.mask == 64
    f = List.last cidr_list
    assert f.first == {8193, 0, 0, 15, 0, 0, 0, 0}
    assert f.last == {8193, 0, 0, 15, 65535, 65535, 65535, 65535}
    assert f.hosts == 18446744073709551616
    assert f.mask == 64
    assert length(cidr_list) == 16
  end

  test "Split error" do
    assert CIDR.parse("1.0.0.0/24") |> CIDR.split(23) == {:error, "New mask must be larger than existing cidr"}
  end

  test "Hosts IPv4" do
    host_list = CIDR.parse("1.0.0.0/24") |> CIDR.hosts |> Enum.map(&(&1))
    assert List.first(host_list) == {1, 0, 0, 0}
    assert List.last(host_list) == {1, 0, 0, 255}
    assert length(host_list) == 256
  end

  test "Hosts IPv6" do
    host_list = CIDR.parse("2001::/126") |> CIDR.hosts |> Enum.map(&(&1))
    assert List.first(host_list) == {8193, 0, 0, 0, 0, 0, 0, 0}
    assert List.last(host_list) == {8193, 0, 0, 0, 0, 0, 0, 3}
    assert length(host_list) == 4
  end

  test "Equal IPv4" do
    assert CIDR.equal?(CIDR.parse("1.0.0.0/24"), CIDR.parse("1.0.0.0/24"))
    assert CIDR.equal?(CIDR.parse("1.0.1.0/24"), CIDR.parse("1.0.0.0/24")) == false
  end

  test "Equal IPv6" do
    assert CIDR.equal?(CIDR.parse("2001::/64"), CIDR.parse("2001::/64"))
    assert CIDR.equal?(CIDR.parse("2001::/64"), CIDR.parse("2002::/64")) == false
  end

  test "Supernet IPv4" do
    assert CIDR.supernet?(CIDR.parse("10.0.0.0/24"), CIDR.parse("10.0.0.128/25"))
    assert CIDR.supernet?(CIDR.parse("10.0.1.0/24"), CIDR.parse("10.0.0.128/25")) == false
    assert CIDR.supernet?(CIDR.parse("10.0.0.128/25"), CIDR.parse("10.0.0.0/24")) == false
  end

  test "Subnet IPv4" do
    assert CIDR.subnet?(CIDR.parse("10.0.0.0/24"), CIDR.parse("10.0.0.128/25")) == false
    assert CIDR.subnet?(CIDR.parse("10.0.1.0/24"), CIDR.parse("10.0.0.128/25")) == false
    assert CIDR.subnet?(CIDR.parse("10.0.0.128/25"), CIDR.parse("10.0.0.0/24"))
  end

end


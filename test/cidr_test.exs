defmodule CIDRTest do
  use ExUnit.Case

  import CIDR, only: [parse: 1, min: 1, max: 1]

  test "127.0.0.1/32 is valid" do
    assert CIDR.is_cidr("127.0.0.1/32") == true
  end

  test "127.0.0.1/64 is invalid" do
    assert CIDR.is_cidr("127.0.0.1/64") == false
  end

  test "127.0.0.1/test is invalid" do
    assert CIDR.is_cidr("127.0.0.1/test") == false
  end

  test "test/32 is invalid" do
    assert CIDR.is_cidr("test/32") == false
  end

  test "127.0.0.1/32/64 is invalid" do
    assert CIDR.is_cidr("127.0.0.1/32/64") == false
  end

  test "false is invalid" do
    assert CIDR.is_cidr(false) == false
  end

  test "Parse 127.0.0.1" do
    assert "127.0.0.1" |> CIDR.parse |> CIDR.is_cidr
  end

  test "Parse 127.0.0.1/24" do
    assert "127.0.0.1/24" |> CIDR.parse |> CIDR.is_cidr
  end

  # Match
  
  test "Matches exactly" do
    assert ("1.2.3.4" |> CIDR.parse |> CIDR.match({1, 1, 1, 1})) == false
    assert ("1.2.3.4" |> CIDR.parse |> CIDR.match({1, 2, 3, 3})) == false
    assert "1.2.3.4" |> CIDR.parse |> CIDR.match({1, 2, 3, 4})
    assert ("1.2.3.4" |> CIDR.parse |> CIDR.match({1, 2, 3, 5})) == false
    assert ("1.2.3.4" |> CIDR.parse |> CIDR.match({255, 255, 255, 255})) == false
  end
  
  test "Matches /24" do
    assert "1.2.3.4/24" |> CIDR.parse |> CIDR.match({1, 2, 3, 1})
    assert "1.2.3.4/24" |> CIDR.parse |> CIDR.match({1, 2, 3, 100})
    assert "1.2.3.4/24" |> CIDR.parse |> CIDR.match({1, 2, 3, 200})
    assert "1.2.3.4/24" |> CIDR.parse |> CIDR.match({1, 2, 3, 255})
  end
  
  test "Returns number of hosts" do
    assert ("1.2.3.4/32" |> CIDR.parse |> CIDR.hosts) == 1
    assert ("1.2.3.4/31" |> CIDR.parse |> CIDR.hosts) == 2
    assert ("1.2.3.4/30" |> CIDR.parse |> CIDR.hosts) == 4
    assert ("1.2.3.4/29" |> CIDR.parse |> CIDR.hosts) == 8
    assert ("1.2.3.4/28" |> CIDR.parse |> CIDR.hosts) == 16
    assert ("1.2.3.4/27" |> CIDR.parse |> CIDR.hosts) == 32
    assert ("1.2.3.4/26" |> CIDR.parse |> CIDR.hosts) == 64
    assert ("1.2.3.4/25" |> CIDR.parse |> CIDR.hosts) == 128
    assert ("1.2.3.4/24" |> CIDR.parse |> CIDR.hosts) == 256
    assert ("1.2.3.4/23" |> CIDR.parse |> CIDR.hosts) == 512
    assert ("1.2.3.4/22" |> CIDR.parse |> CIDR.hosts) == 1024
    assert ("1.2.3.4/21" |> CIDR.parse |> CIDR.hosts) == 2048
    assert ("1.2.3.4/20" |> CIDR.parse |> CIDR.hosts) == 4096
    assert ("1.2.3.4/19" |> CIDR.parse |> CIDR.hosts) == 8192
    assert ("1.2.3.4/18" |> CIDR.parse |> CIDR.hosts) == 16384
    assert ("1.2.3.4/17" |> CIDR.parse |> CIDR.hosts) == 32768
    assert ("1.2.3.4/16" |> CIDR.parse |> CIDR.hosts) == 65536
    assert ("1.2.3.4/15" |> CIDR.parse |> CIDR.hosts) == 131072
    assert ("1.2.3.4/14" |> CIDR.parse |> CIDR.hosts) == 262144
    assert ("1.2.3.4/13" |> CIDR.parse |> CIDR.hosts) == 524288
    assert ("1.2.3.4/12" |> CIDR.parse |> CIDR.hosts) == 1048576
    assert ("1.2.3.4/11" |> CIDR.parse |> CIDR.hosts) == 2097152
    assert ("1.2.3.4/10" |> CIDR.parse |> CIDR.hosts) == 4194304
    assert ("1.2.3.4/9"  |> CIDR.parse |> CIDR.hosts) == 8388608
    assert ("1.2.3.4/8"  |> CIDR.parse |> CIDR.hosts) == 16777216
    assert ("1.2.3.4/7"  |> CIDR.parse |> CIDR.hosts) == 33554432
    assert ("1.2.3.4/6"  |> CIDR.parse |> CIDR.hosts) == 67108864
    assert ("1.2.3.4/5"  |> CIDR.parse |> CIDR.hosts) == 134217728
    assert ("1.2.3.4/4"  |> CIDR.parse |> CIDR.hosts) == 268435456
    assert ("1.2.3.4/3"  |> CIDR.parse |> CIDR.hosts) == 536870912
    assert ("1.2.3.4/2"  |> CIDR.parse |> CIDR.hosts) == 1073741824
    assert ("1.2.3.4/1"  |> CIDR.parse |> CIDR.hosts) == 2147483648
    assert ("1.2.3.4/0"  |> CIDR.parse |> CIDR.hosts) == 4294967296
  end
  
  test "Returns correct min/max IP addresses." do
    assert ("1.2.3.4/24"       |> parse |> min) == { 1, 2, 3, 0 }
    assert ("1.2.3.4/24"       |> parse |> max) == { 1, 2, 3, 255 }
    assert ("192.168.100.0/22" |> parse |> min) == { 192, 168, 100, 0 }
    assert ("192.168.100.0/22" |> parse |> max) == { 192, 168, 103, 255 }
  end

end

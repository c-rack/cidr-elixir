defmodule CIDRTest do
  use ExUnit.Case

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

end

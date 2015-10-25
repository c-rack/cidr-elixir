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

  test "Match can also take a binary" do
    assert "1.2.3.4/24" |> CIDR.parse |> CIDR.match("1.2.3.9")
  end
end

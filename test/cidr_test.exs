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

  test "Parse of single IP should return exactly 1 host" do
    cidr1 = CIDR.parse("127.0.0.1")
    assert cidr1.hosts == 1
    cidr2 = CIDR.parse("::1")
    assert cidr2.hosts == 1
  end

  # Match

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

    assert CIDR.match(cidr, {1,2,3,257}) == {:error, "Tuple is not a valid IP address."}
    assert CIDR.match(cidr, {0, 0, 0, 0, 0, 0, 0, 100000}) == {:error, "Argument must be a binary or IP tuple of the same protocol."}
    assert CIDR.match(cidr, "This is not an IP") == {:error, :einval}
  end

  test "Match! error handling" do
    cidr = CIDR.parse("1.2.3.4/24")

    assert_raise ArgumentError, "Tuple is not a valid IP address.", fn ->
      CIDR.match!(cidr, {1,2,3,257})
    end
    assert_raise ArgumentError, "Argument must be a binary or IP tuple of the same protocol.", fn ->
      CIDR.match!(cidr, {0, 0, 0, 0, 0, 0, 0, 100000})
    end
    assert_raise ArgumentError, fn ->
      CIDR.match!(cidr, "This is not an IP")
    end
  end
end

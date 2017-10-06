defmodule SaltyTest do
  use ExUnit.Case
  doctest Salty

  test "greets the world" do
    assert Salty.hello() == :world
  end
end

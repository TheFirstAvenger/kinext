defmodule KinextTest do
  use ExUnit.Case
  doctest Kinext

  test "greets the world" do
    assert Kinext.hello() == :world
  end
end

defmodule NervesNodeTest do
  use ExUnit.Case
  doctest NervesNode

  test "greets the world" do
    assert NervesNode.hello() == :world
  end
end

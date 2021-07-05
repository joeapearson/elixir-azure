defmodule AzureTest do
  use ExUnit.Case
  doctest Azure

  test "greets the world" do
    assert Azure.hello() == :world
  end
end

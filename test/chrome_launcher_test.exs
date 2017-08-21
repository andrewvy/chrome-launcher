defmodule ChromeLauncherTest do
  use ExUnit.Case
  doctest ChromeLauncher

  test "greets the world" do
    assert ChromeLauncher.hello() == :world
  end
end

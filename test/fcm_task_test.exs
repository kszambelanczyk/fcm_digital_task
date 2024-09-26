defmodule FcmTaskTest do
  use ExUnit.Case
  doctest FcmTask

  test "greets the world" do
    assert FcmTask.hello() == :world
  end
end

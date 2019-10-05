defmodule Test.Support.AssertNestedTest do
  # run in parallel with other tests
  use ExUnit.Case, async: true

  # run tests specified in function docs of that module (iex>)
  doctest Test.Support.AssertNested
end

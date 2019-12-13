defmodule Weaver.GraphQL.Scalar.Default do
  def input(_type, value) do
    {:ok, value}
  end

  def output(_type, value) do
    {:ok, value}
  end
end

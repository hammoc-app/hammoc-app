defmodule Weaver.GraphQL.Enum.Default do
  def output(_default, enum) do
    {:error, {:unknown_enum, enum}}
  end
end

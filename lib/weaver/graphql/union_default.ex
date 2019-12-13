defmodule Weaver.GraphQL.Union.Default do
  def execute(otherwise) do
    {:error, {:unknown_type, otherwise}}
  end
end

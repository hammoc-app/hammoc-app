defmodule Weaver.GraphQL.Interface.Default do
  def execute(%{:__struct__ => module}) do
    type =
      if function_exported?(module, :graphql_type, 0) do
        module.graphql_type()
      else
        module
        |> to_string()
        |> String.split(".")
        |> Enum.reverse()
        |> Enum.take(2)
        |> Enum.reverse()
        |> Enum.join()
      end

    {:ok, String.to_atom(type)}
  end

  def execute(otherwise) do
    {:error, {:unknown_type, otherwise}}
  end
end

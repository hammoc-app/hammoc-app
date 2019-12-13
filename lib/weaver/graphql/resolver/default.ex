defmodule Weaver.GraphQL.Resolver.Default do
  def execute(_ctx, %{__struct__: _} = obj, field, _args) do
    try do
      value = Map.get(obj, String.to_existing_atom(field), :null)
      {:ok, value}
    catch
      ArgumentError -> {:error, :null}
    end
  end

  def execute(_ctx, %{"tshirt" => obj}, "tshirt", _args) do
    {:ok, obj}
  end

  def execute(_ctx, _obj, field, _args) do
    {:error, {:unknown_field, field}}
  end
end

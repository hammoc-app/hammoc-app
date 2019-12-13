defmodule Weaver.GraphQL.Resolver.Mutation do
  def execute(%{op_type: :mutation}, _obj, "createTShirt", %{"input" => _args}) do
    {:ok, %{}}
  end
end

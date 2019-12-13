defmodule Weaver.GraphQL.Resolver.QueryRoot do
  def execute(_ctx, :none, "node", %{"id" => id}) do
    {:ok, %Weaver.Twitter.User{id: id}}
  end
end

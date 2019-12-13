defmodule Weaver.GraphQL.Query do
  @moduledoc false

  defstruct result: nil,
            operation: nil,
            query: nil,
            environment: nil,
            params: %{}

  defmodule Result do
    @moduledoc """
    The result of running a query
    """

    defstruct data: nil, aux: nil, errors: nil
  end
end

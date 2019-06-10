defmodule Test.Support.UeberauthCallback do
  @moduledoc """
  Behaviour for overriding `Ueberauth.Strategy` callback values.

  This is used for the `Test.Support.Stubs.UeberauthStrategy` stub.
  """

  @callback result() :: any()
end

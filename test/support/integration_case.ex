defmodule HammocWeb.IntegrationCase do
  @moduledoc """
  This module defines the test case for testing a user
  journey defined by a sequence of requests and responses.

  Such tests rely on `PhoenixIntegration` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use HammocWeb.ConnCase
      use PhoenixIntegration

      import Test.Support.Factory

      import Mox
    end
  end
end

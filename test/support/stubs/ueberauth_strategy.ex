defmodule Test.Support.Stubs.UeberauthStrategy do
  @moduledoc """
  A stub for `Ueberauth.Strategy`.

  Implements its default functionality and is overridable by using `Mox`
  on the `Test.Support.Mocks.UeberauthCallback.result/0` mock function.
  """

  use Ueberauth.Strategy

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  def handle_request!(conn) do
    conn
    |> redirect!(callback_url(conn))
  end

  def handle_callback!(conn) do
    case Test.Support.Mocks.UeberauthCallback.result() do
      {:ok, fields} ->
        auth =
          conn
          |> auth()
          |> set_fields(fields)

        assign(conn, :ueberauth_auth, auth)

      {:error, error = %Ueberauth.Failure.Error{}} ->
        assign(conn, :ueberauth_failure, %Ueberauth.Failure{
          errors: [error],
          provider: strategy_name(conn),
          strategy: strategy(conn)
        })
    end
  end

  defp set_fields(struct, fields) do
    Map.merge(struct, Util.Keyword.to_map(fields))
  end

  def uid(_conn) do
    "abc123"
  end

  def info(_conn) do
    %Info{}
  end

  def credentials(_conn) do
    %Credentials{token: "9yecb129ce", secret: "qn9sbcs19scgb"}
  end

  def extra(_conn) do
    %Extra{raw_info: %{token: "9yecb129ce", user: %{}}}
  end
end

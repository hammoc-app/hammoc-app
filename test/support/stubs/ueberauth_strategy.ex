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
    conn
    |> assign(:ueberauth_auth, auth(conn))
  end

  def uid(_conn) do
    from_mock(:uid) || "abc123"
  end

  def info(_conn) do
    from_mock(:info) || %Info{}
  end

  def credentials(_conn) do
    from_mock(:credentials) || %Credentials{token: "9yecb129ce", secret: "qn9sbcs19scgb"}
  end

  def extra(_conn) do
    from_mock(:extra) ||
      %Extra{
        raw_info: %{
          token: "9yecb129ce",
          user: %{}
        }
      }
  end

  defp from_mock(key) do
    {:ok, result} = Test.Support.Mocks.UeberauthCallback.result()
    Keyword.get(result, key)
  end
end

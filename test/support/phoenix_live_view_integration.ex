defmodule PhoenixLiveViewIntegration do
  @moduledoc "Helper functions for LiveView integration tests, inspired by the PhoenixIntegration library."

  defmacro __using__(_opts) do
    quote do
      require Phoenix.LiveViewTest

      import PhoenixLiveViewIntegration

      alias PhoenixLiveViewIntegration.State

      def live(conn, path) do
        {:ok, view, html} = Phoenix.LiveViewTest.live(conn, path)

        %State{conn: conn, view: view, html: html}
      end
    end
  end

  alias __MODULE__.ResponseError

  defmodule State do
    @moduledoc "Token struct used to chain integration actions and assertions in tests."

    defstruct [:conn, :view, :html, extra: %{}]
  end

  defmodule ResponseError do
    @moduledoc false
    defexception message: "#{IO.ANSI.red()}The conn's response was not formed as expected\n"
  end

  def assert_rendered(state = %State{}, conditions) do
    conn = Map.put(state.conn, :resp_body, state.html)

    Enum.each(conditions, fn {condition, value} ->
      case condition do
        :body -> assert_body(conn, value)
        :element -> assert_element(conn, value)
      end
    end)

    state
  end

  def refute_rendered(state = %State{}, conditions) do
    conn = Map.put(state.conn, :resp_body, state.html)

    Enum.each(conditions, fn {condition, value} ->
      case condition do
        :body -> refute_body(conn, value)
        :element -> refute_element(conn, value)
      end
    end)

    state
  end

  defp assert_element(conn, element, err_type \\ :body) do
    selector =
      case element do
        selector when is_binary(selector) -> selector
        [selector, text: text] -> "#{selector}:fl-contains('#{text}')"
      end

    if Floki.find(conn.resp_body, selector) != [] do
      conn
    else
      msg =
        error_msg_type(conn, err_type) <>
          error_msg_expected("to find \"#{selector}\"") <>
          error_msg_found("Not in the response body\n") <> IO.ANSI.yellow() <> conn.resp_body

      raise %ResponseError{message: msg}
    end
  end

  defp refute_element(conn, selector, err_type \\ :body) do
    if Floki.find(conn.resp_body, selector) != [] do
      msg =
        error_msg_type(conn, err_type) <>
          error_msg_expected("NOT to find \"#{selector}\"") <>
          error_msg_found("in the response body\n") <> IO.ANSI.yellow() <> conn.resp_body

      raise %ResponseError{message: msg}
    else
      conn
    end
  end

  defp assert_body(conn, expected, err_type \\ :body) do
    if conn.resp_body =~ expected do
      conn
    else
      msg =
        error_msg_type(conn, err_type) <>
          error_msg_expected("to find \"#{expected}\"") <>
          error_msg_found("Not in the response body\n") <> IO.ANSI.yellow() <> conn.resp_body

      raise %ResponseError{message: msg}
    end
  end

  defp refute_body(conn, expected, err_type \\ :body) do
    if conn.resp_body =~ expected do
      msg =
        error_msg_type(conn, err_type) <>
          error_msg_expected("NOT to find \"#{expected}\"") <>
          error_msg_found("in the response body\n") <> IO.ANSI.yellow() <> conn.resp_body

      raise %ResponseError{message: msg}
    else
      conn
    end
  end

  defp error_msg_type(conn, type) do
    "#{IO.ANSI.red()}The conn's response was not formed as expected\n" <>
      "#{IO.ANSI.green()}Error verifying #{IO.ANSI.cyan()}:#{type}\n" <>
      "#{IO.ANSI.green()}Request path: #{IO.ANSI.yellow()}#{conn_request_path(conn)}\n" <>
      "#{IO.ANSI.green()}Request method: #{IO.ANSI.yellow()}#{conn.method}\n" <>
      "#{IO.ANSI.green()}Request params: #{IO.ANSI.yellow()}#{inspect(conn.params)}\n"
  end

  defp error_msg_expected(msg) do
    "#{IO.ANSI.green()}Expected: #{IO.ANSI.red()}#{msg}\n"
  end

  defp error_msg_found(msg) do
    "#{IO.ANSI.green()}Found: #{IO.ANSI.red()}#{msg}\n"
  end

  defp conn_request_path(conn) do
    conn.request_path <>
      case conn.query_string do
        nil -> ""
        "" -> ""
        query -> "?" <> query
      end
  end
end

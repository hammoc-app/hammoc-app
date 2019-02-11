defmodule HammocWeb.PageControllerTest do
  use HammocWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Open up your Hammoc"
  end
end

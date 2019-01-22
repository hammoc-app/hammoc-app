defmodule HammocWeb.PageControllerTest do
  use HammocWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Open up your Hammoc"
  end
end

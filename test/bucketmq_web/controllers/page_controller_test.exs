defmodule BucketMQWeb.PageControllerTest do
  use BucketMQWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "BucketMQ"
  end
end

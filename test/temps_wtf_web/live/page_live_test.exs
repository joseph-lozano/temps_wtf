defmodule TempsWTFWeb.PageLiveTest do
  use TempsWTFWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Temps.WTF"
    assert render(page_live) =~ "Temps.WTF"
  end
end

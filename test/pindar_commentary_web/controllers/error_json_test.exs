defmodule PindarCommentaryWeb.ErrorJSONTest do
  use PindarCommentaryWeb.ConnCase, async: true

  test "renders 404" do
    assert PindarCommentaryWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert PindarCommentaryWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end

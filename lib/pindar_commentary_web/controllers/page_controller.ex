defmodule PindarCommentaryWeb.PageController do
  use PindarCommentaryWeb, :controller

  def home(conn, _params) do
    collections = Kodon.Texts.collections(PindarCommentaryWeb.Site)
    render(conn, :home, collections: collections)
  end

  def about(conn, _params) do
    render(conn, :about)
  end
end

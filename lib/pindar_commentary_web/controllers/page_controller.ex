defmodule PindarCommentaryWeb.PageController do
  use PindarCommentaryWeb, :controller

  def home(conn, _params) do
    collections = PindarCommentary.Texts.collections()
    render(conn, :home, collections: collections)
  end

  def about(conn, _params) do
    render(conn, :about)
  end
end

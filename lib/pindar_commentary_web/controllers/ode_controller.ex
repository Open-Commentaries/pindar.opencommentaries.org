defmodule PindarCommentaryWeb.OdeController do
  use PindarCommentaryWeb, :controller

  def show(conn, %{"cts_urn" => full_urn}) do
    partial_urn = String.replace_leading(full_urn, "urn:cts:greekLit:", "")

    case Kodon.Texts.get_poem(PindarCommentaryWeb.Site, partial_urn) do
      {:ok, poem} ->
        comments = Kodon.Commentary.get_comments_for_poem(PindarCommentaryWeb.Site, partial_urn)
        collections = Kodon.Texts.collections(PindarCommentaryWeb.Site)
        render(conn, :show, poem: poem, comments: comments, collections: collections)

      :error ->
        conn
        |> put_status(:not_found)
        |> put_view(PindarCommentaryWeb.ErrorHTML)
        |> render(:"404")
    end
  end
end

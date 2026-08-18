defmodule PindarCommentaryWeb.OdeController do
  use PindarCommentaryWeb, :controller

  def show(conn, %{"cts_urn" => full_urn}) do
    partial_urn = String.replace_leading(full_urn, "urn:cts:greekLit:", "")

    case PindarCommentary.Texts.get_poem(partial_urn) do
      {:ok, poem} ->
        comments = PindarCommentary.Commentary.get_comments_for_poem(partial_urn)
        collections = PindarCommentary.Texts.collections()
        render(conn, :show, poem: poem, comments: comments, collections: collections)

      :error ->
        conn
        |> put_status(:not_found)
        |> put_view(PindarCommentaryWeb.ErrorHTML)
        |> render(:"404")
    end
  end
end

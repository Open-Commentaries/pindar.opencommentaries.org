defmodule PindarCommentaryWeb.Site do
  @moduledoc """
  This app's `Kodon.Site` implementation — points Kodon at the Pindar TEI and
  commentary directories and this app's endpoint/router.
  """

  @behaviour Kodon.Site

  @impl true
  def tei_dir, do: Path.join(:code.priv_dir(:pindar_commentary), "static/tei/data")

  @impl true
  def commentary_dir, do: Path.join(:code.priv_dir(:pindar_commentary), "static/commentary")

  @impl true
  def collections, do: ["tlg0033.tlg001", "tlg0033.tlg002", "tlg0033.tlg003", "tlg0033.tlg004"]

  @impl true
  def endpoint, do: PindarCommentaryWeb.Endpoint

  @impl true
  def router, do: PindarCommentaryWeb.Router

  @impl true
  def extra_routes, do: ["/", "/about"]
end

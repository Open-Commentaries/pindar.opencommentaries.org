defmodule Mix.Tasks.ServeStatic do
  @moduledoc """
  Starts a local development server for the built site.

  ## Usage

      mix serve_static          # serves on port 4001
      mix serve_static 8080     # serves on custom port
  """

  use Mix.Task

  @shortdoc "Start a local dev server for the built site"

  @impl Mix.Task
  def run(args) do
    port =
      case args do
        [port_str | _] -> String.to_integer(port_str)
        [] -> 4001
      end

    Kodon.StaticSite.serve(PindarCommentaryWeb.Site, port: port)
  end
end

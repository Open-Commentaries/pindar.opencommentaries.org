defmodule Mix.Tasks.GenerateStatic do
  @moduledoc "Generate a static site for the Pindar Commentary"
  use Mix.Task

  # Must run in :static (see config/static.exs) so the endpoint's
  # code_reloader/live_reload plugs are compiled out — otherwise the generated
  # pages embed a live-reload iframe pointing at /phoenix/live_reload/frame,
  # which doesn't exist once deployed. code_reloading? is baked in at compile
  # time, so a runtime env var isn't enough; this has to be a real Mix env.
  @preferred_cli_env :static

  @shortdoc "Generates index.html for each route and copies compiled assets"
  def run(_) do
    Mix.Task.run("app.start")

    output_dir = Kodon.StaticSite.generate(PindarCommentaryWeb.Site)
    Mix.shell().info("Static site generated at #{output_dir}")
  end
end

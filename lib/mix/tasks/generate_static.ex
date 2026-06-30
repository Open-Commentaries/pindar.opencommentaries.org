defmodule Mix.Tasks.GenerateStatic do
  @moduledoc "Generate a static site for the Pindar Commentary"
  use Mix.Task

  @endpoint PindarCommentaryWeb.Endpoint
  use PindarCommentaryWeb, :verified_routes
  import Phoenix.ConnTest

  @shortdoc "Generates index.html for each route and copies compiled assets"
  def run(_) do
    Mix.Task.run("app.start")

    output_dir = output_dir()

    routes = ["/", "/about"] ++ ode_routes()
    Enum.each(routes, &generate_html_for_route(&1, output_dir))

    copy_assets(output_dir)
  end

  defp ode_routes do
    PindarCommentary.Texts.collections()
    |> Enum.flat_map(fn collection ->
      Enum.map(collection.poems, fn poem -> "/" <> poem["urn"] end)
    end)
  end

  defp generate_html_for_route(route_path, output_dir) do
    conn = build_conn()
    conn = get(conn, route_path)
    resp = html_response(conn, 200)

    page_dir = Path.join(output_dir, route_path)
    File.mkdir_p!(page_dir)
    File.write!(Path.join(page_dir, "index.html"), resp)
    Mix.shell().info("  generated #{route_path}")
  end

  defp copy_assets(output_dir) do
    # Tailwind writes to priv/static/assets/css/app.css and esbuild to
    # priv/static/assets/js/ in the project source tree. Copy them explicitly
    # so the output dir is self-contained even when :code.priv_dir diverges
    # from the source (e.g. in release builds).
    src = Path.join([File.cwd!(), "priv", "static", "assets"])
    dst = Path.join(output_dir, "assets")

    if File.exists?(src) do
      {:ok, files} = File.cp_r(src, dst)
      Mix.shell().info("  copied #{length(files)} asset(s) to #{dst}")
    else
      Mix.shell().error("No compiled assets found at #{src} — run `mix assets.build` first")
    end
  end

  defp output_dir do
    app_name = Keyword.fetch!(Mix.Project.get().project(), :app)
    Path.join([:code.priv_dir(app_name) |> to_string(), "build"])
  end
end

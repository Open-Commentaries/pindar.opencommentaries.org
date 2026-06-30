defmodule PindarCommentary.Texts do
  @json_dir "priv/static/json/tlg0033"

  @collections ["tlg001", "tlg002", "tlg003", "tlg004"]

  def collections do
    Enum.map(@collections, &load_collection/1)
  end

  # Accepts a partial URN like "tlg0033.tlg001.perseus-grc2:1".
  # Returns {:ok, poem_data} or :error.
  def get_poem(partial_urn) do
    with [work_version, n] <- String.split(partial_urn, ":", parts: 2),
         [_author, _work_id, _version] <- String.split(work_version, "."),
         path when not is_nil(path) <- json_path_for(work_version),
         {:ok, data} <- File.read(path),
         {:ok, decoded} <- Jason.decode(data),
         textpart when not is_nil(textpart) <- find_textpart(decoded["textparts"], n) do
      elements = Enum.filter(decoded["elements"], &(&1["textpart_index"] == textpart["index"]))
      {:ok, %{title: decoded["title"], urn: textpart["urn"], textpart: textpart, elements: elements}}
    else
      _ -> :error
    end
  end

  defp find_textpart(textparts, n) do
    Enum.find(textparts, &(&1["n"] == n and &1["subtype"] == "poem"))
  end

  defp json_path_for(work_version) do
    # work_version is e.g. "tlg0033.tlg001.perseus-grc2"
    case String.split(work_version, ".") do
      [_author, work_id, _version] ->
        candidate = Path.join([@json_dir, work_id, "#{work_version}.json"])
        # Fall back to searching the directory if the exact file doesn't exist
        if File.exists?(candidate) do
          candidate
        else
          @json_dir
          |> Path.join(work_id)
          |> then(fn dir ->
            case File.ls(dir) do
              {:ok, files} -> files |> Enum.find(&(Path.basename(&1, ".json") == work_version)) |> then(&if(&1, do: Path.join(dir, &1)))
              _ -> nil
            end
          end)
        end

      _ ->
        nil
    end
  end

  defp load_collection(work_id) do
    path =
      @json_dir
      |> Path.join(work_id)
      |> File.ls!()
      |> Enum.find(&String.contains?(&1, "grc"))
      |> then(&Path.join([@json_dir, work_id, &1]))

    data = path |> File.read!() |> Jason.decode!()

    poems =
      data["textparts"]
      |> Enum.filter(&(&1["subtype"] == "poem"))
      |> Enum.sort_by(& &1["index"])

    %{title: data["title"], urn: data["urn"], poems: poems}
  end
end

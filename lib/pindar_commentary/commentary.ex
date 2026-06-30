defmodule PindarCommentary.Commentary do
  @commentary_dir "priv/static/commentary"

  # Returns comments for a poem, given a partial URN like "tlg0033.tlg001.perseus-grc2:5".
  # Matches against all commentary files, ignoring version identifiers.
  def get_comments_for_poem(partial_urn) do
    {work_id, poem_n} = parse_partial_urn(partial_urn)

    @commentary_dir
    |> File.ls!()
    |> Enum.flat_map(fn filename ->
      @commentary_dir |> Path.join(filename) |> parse_file()
    end)
    |> Enum.filter(&matches_poem?(&1.urn, work_id, poem_n))
    |> Enum.sort_by(& &1.citation_start)
  end

  defp parse_partial_urn(partial_urn) do
    case String.split(partial_urn, ":", parts: 2) do
      [work_version, poem_n] -> {strip_version(work_version), poem_n}
      _ -> {partial_urn, nil}
    end
  end

  # "tlg0033.tlg001.perseus-grc2" -> "tlg0033.tlg001"
  # "tlg0033.tlg001" -> "tlg0033.tlg001"
  defp strip_version(work_version) do
    work_version |> String.split(".") |> Enum.take(2) |> Enum.join(".")
  end

  defp matches_poem?(urn, work_id, poem_n) do
    # urn like "urn:cts:greekLit:tlg0033.tlg001:5.1-5.8"
    # or       "urn:cts:greekLit:tlg0033.tlg001.perseus-grc2:5.2@token"
    with [_, rest] <- String.split(urn, "greekLit:", parts: 2),
         [work_version, citation] <- String.split(rest, ":", parts: 2) do
      strip_version(work_version) == work_id and poem_n_from_citation(citation) == poem_n
    else
      _ -> false
    end
  end

  # "5.1-5.8" -> "5",  "5.3" -> "5",  "5.2@token" -> "5"
  defp poem_n_from_citation(citation) do
    citation |> String.split([".", "@"]) |> List.first()
  end

  defp parse_file(path) do
    content = File.read!(path)

    case String.split(content, "\n---\n") do
      [frontmatter_chunk | comment_chunks] ->
        frontmatter = frontmatter_chunk |> String.trim_leading("---\n") |> parse_frontmatter()

        comment_chunks
        |> Enum.map(&parse_comment_block(&1, frontmatter))
        |> Enum.reject(&is_nil/1)

      _ ->
        []
    end
  end

  defp parse_frontmatter(text) do
    text
    |> String.split("\n")
    |> Enum.reduce(%{}, fn line, acc ->
      case String.split(line, ": ", parts: 2) do
        [k, v] -> Map.put(acc, String.trim(k), String.trim(v))
        _ -> acc
      end
    end)
  end

  defp parse_comment_block(block, frontmatter) do
    case String.trim(block) do
      "" ->
        nil

      trimmed ->
        case String.split(trimmed, "\n") do
          ["@urn:" <> _ = urn_line | rest] ->
            urn = String.trim_leading(urn_line, "@")
            {meta_lines, body_lines} = Enum.split_while(rest, &String.starts_with?(&1, ":"))
            meta = parse_metadata(meta_lines)
            body = body_lines |> Enum.join("\n") |> String.trim()

            %{
              urn: urn,
              citation_urn: meta["citation_urn"],
              body: body,
              author: frontmatter["author"],
              shortname: frontmatter["shortname"],
              citation_start: citation_start_from_urn(urn)
            }

          _ ->
            nil
        end
    end
  end

  defp parse_metadata(lines) do
    Enum.reduce(lines, %{}, fn line, acc ->
      case Regex.run(~r/^:(\w+): (.*)$/, line) do
        [_, key, value] -> Map.put(acc, key, value)
        _ -> acc
      end
    end)
  end

  defp citation_start_from_urn(urn) do
    # Extract {poem_n, line_n} for sorting, e.g. "...tlg001:5.1-5.8" -> {5, 1}
    with [_, _, _, citation_part] <- String.split(urn, ":", parts: 4),
         first_ref <- citation_part |> String.split("-") |> List.first(),
         clean <- first_ref |> String.split("@") |> List.first(),
         [poem | rest] <- String.split(clean, "."),
         {poem_n, _} <- Integer.parse(poem) do
      line_n =
        case rest do
          [l | _] -> elem(Integer.parse(l), 0)
          _ -> 0
        end

      {poem_n, line_n}
    else
      _ -> {0, 0}
    end
  rescue
    _ -> {0, 0}
  end

  def render_body(markdown) do
    MDEx.to_html!(markdown, extension: [strikethrough: true, autolink: true])
  end

  # "urn:cts:greekLit:tlg0033.tlg001:5.1-5.8" -> "5.1–5.8"
  # "urn:cts:greekLit:tlg0033.tlg001.perseus-grc2:5.2@token" -> "5.2"
  def citation_from_urn(urn) do
    urn
    |> String.split(":", parts: 5)
    |> List.last()
    |> String.split("@")
    |> List.first()
    |> String.replace("-", "–")
  end
end

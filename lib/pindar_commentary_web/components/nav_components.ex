defmodule PindarCommentaryWeb.NavComponents do
  use Phoenix.Component

  attr :collection, :map, required: true
  attr :current_urn, :string, required: true

  def nav_collection(assigns) do
    ~H"""
    <li>
      <details open={String.starts_with?(@current_urn, @collection.urn)}>
        <summary class="font-semibold"><%= @collection.title %></summary>
        <ul>
          <%= for poem <- @collection.poems do %>
            <.nav_poem
              poem={poem}
              collection_title={@collection.title}
              current_urn={@current_urn}
            />
          <% end %>
        </ul>
      </details>
    </li>
    """
  end

  attr :poem, :map, required: true
  attr :collection_title, :string, required: true
  attr :current_urn, :string, required: true

  def nav_poem(assigns) do
    ~H"""
    <li>
      <a
        href={"/" <> @poem["urn"]}
        class={if @poem["urn"] == @current_urn, do: "menu-active", else: ""}
      >
        <%= @collection_title %> <%= @poem["n"] %>
      </a>
    </li>
    """
  end
end

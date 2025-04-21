defmodule IslandGameWeb.UserLive do
  use Phoenix.LiveView

  @impl true
  def mount(%{"game_id" => game_id}, _session, socket) do
    user_id = Enum.random(1..999)
    topic = "game:#{game_id}"

    if connected?(socket), do: IslandGameWeb.Endpoint.subscribe(topic)

    {:ok,
     socket
     |> assign(:game_id, game_id)
     |> assign(:current_user, %{id: user_id, username: nil})
     |> assign(:game_data, nil)}
  end

  @impl true
  def handle_info(%{event: "new_round", payload: game_data}, socket) do
    {:noreply, assign(socket, :game_data, game_data)}
  end

  @impl true
  def handle_event("set_username", %{"username" => username}, socket) do
    {:noreply, assign(socket, :current_user, %{id: socket.assigns.current_user.id, username: username})}
  end

  @impl true
  def handle_event("submit_response", %{"fields" => fields}, socket) do
    IslandGameWeb.Endpoint.broadcast("response:#{socket.assigns.game_id}", "user_response", %{
      user_id: socket.assigns.current_user.id,
      username: socket.assigns.current_user.username,
      fields: fields,
      round_id: socket.assigns.game_data.round_id
    })

    {:noreply, socket}
  end
end

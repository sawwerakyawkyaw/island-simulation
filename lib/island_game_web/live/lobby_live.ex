defmodule IslandGameWeb.LobbyLive do
  use IslandGameWeb, :live_view
  alias IslandGame.GameServer

  def mount(%{"room_id" => room_id}, _session, socket) do
    case GameServer.get_room(room_id) do
      {:ok, room} ->
        topic = "response:#{room_id}"
        if connected?(socket), do: IslandGameWeb.Endpoint.subscribe(topic)

        {:ok,
         socket
         |> assign(:room_id, room_id)
         |> assign(:room_name, room.name)
         |> assign(:game_started, false)
         |> assign(:joined_users, [])}

      {:error, :not_found} ->
        {:ok,
         socket
         |> put_flash(:error, "Room not found")
         |> redirect(to: ~p"/")}
    end
  end

  def handle_event("start_game", _params, socket) do
    case GameServer.start_game(socket.assigns.room_id) do
      {:ok, _game} ->
        {:noreply,
         socket
         |> put_flash(:info, "Game started!")
         |> redirect(to: ~p"/game/#{socket.assigns.room_id}/admin")}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to start game")}
    end
  end

  def handle_info(
        %{event: "user_joined", payload: %{username: username, joined_at: joined_at}},
        socket
      ) do
    new_user = %{name: username, joined_at: joined_at}
    updated_users = [new_user | socket.assigns.joined_users]

    {:noreply, assign(socket, :joined_users, updated_users)}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-4">Room: {@room_name}</h1>
      <p class="text-xl mb-4">Room ID: {@room_id}</p>

      <div class="mb-8">
        <h2 class="text-2xl font-semibold mb-2">Recently Joined Players:</h2>
        <ul class="list-disc pl-4">
          <%= for user <- @joined_users do %>
            <li>
              {user.name}
            </li>
          <% end %>
        </ul>
      </div>

      <button
        phx-click="start_game"
        class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
        disabled={@game_started}
      >
        Start Game
      </button>
    </div>
    """
  end
end

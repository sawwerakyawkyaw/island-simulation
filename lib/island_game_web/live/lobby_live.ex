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
end

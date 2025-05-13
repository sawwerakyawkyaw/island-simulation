defmodule IslandGameWeb.LobbyLive do
  @moduledoc """
  Handles the game lobby, allowing users to join or create games.
  """
  use IslandGameWeb, :live_view
  alias IslandGame.GameServer
  require Logger

  @doc """
  Mounts the LobbyLive view, subscribes to room events, and assigns initial state.
  Redirects if the room is not found.
  """
  def mount(%{"room_id" => room_id}, _session, socket) do
    Logger.info("Attempting to mount lobby for room: #{room_id}")

    case GameServer.get_room(room_id) do
      {:ok, room} ->
        Logger.info("Successfully found room: #{inspect(room)}")
        topic = "response:#{room_id}"
        if connected?(socket), do: IslandGameWeb.Endpoint.subscribe(topic)

        {:ok,
         socket
         |> assign(:room_id, room_id)
         |> assign(:room_name, room.name)
         |> assign(:game_started, false)
         |> assign(:joined_users, [])}

      {:error, :not_found} ->
        Logger.error("Room not found: #{room_id}")

        {:ok,
         socket
         |> put_flash(:error, "Room not found")
         |> redirect(to: ~p"/")}
    end
  end

  @doc """
  Handles the "start_game" event, attempting to start the game for the current room.
  Redirects to the admin game view on success or shows an error flash.
  """
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

  @doc """
  Handles the "user_joined" info message, updating the list of joined users.
  """
  def handle_info(
        %{event: "user_joined", payload: %{username: username, joined_at: joined_at}},
        socket
      ) do
    new_user = %{name: username, joined_at: joined_at}
    updated_users = [new_user | socket.assigns.joined_users]

    {:noreply, assign(socket, :joined_users, updated_users)}
  end
end

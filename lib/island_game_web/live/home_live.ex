defmodule IslandGameWeb.HomeLive do
  @moduledoc """
  The main landing page LiveView for the application.
  """
  use IslandGameWeb, :live_view
  alias IslandGame.GameServer
  require Logger

  # Mounts the HomeLive view and initializes the socket assigns.
  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       room_id: nil,
       room_name: nil,
       error: nil,
       show_username_modal: false,
       username: nil
     )}
  end

  # Handles the "create_room" event, generating a new room ID and creating the room.
  # Redirects to the lobby on success or shows an error.
  def handle_event("create_room", %{"room_name" => room_name}, socket) do
    room_id = generate_room_id()
    Logger.info("Attempting to create room with ID: #{room_id} and name: #{room_name}")

    case GameServer.create_room(room_id, room_name) do
      {:ok, room} ->
        Logger.info("Room created successfully: #{inspect(room)}")

        {:noreply,
         socket
         |> put_flash(:info, "Room created successfully!")
         |> redirect(to: ~p"/lobby/#{room_id}")}

      {:error, reason} ->
        Logger.error("Failed to create room: #{inspect(reason)}")

        {:noreply,
         socket
         |> put_flash(:error, "Failed to create room")
         |> assign(error: "Failed to create room")}
    end
  end

  # Handles the "join_room" event, validating the room ID and game status.
  # Shows a username modal if the room is joinable.
  def handle_event("join_room", %{"room_id" => room_id}, socket) do
    case GameServer.get_room(room_id) do
      {:ok, _room} ->
        case GameServer.game_started?(room_id) do
          {:ok, true} ->
            {:noreply,
             socket
             |> assign(error: "Game has already started")}

          {:ok, false} ->
            {:noreply,
             socket
             |> assign(show_username_modal: true, room_id: room_id)}

          {:error, _reason} ->
            {:noreply,
             socket
             |> put_flash(:error, "Failed to check game status")
             |> assign(error: "Failed to check game status")}
        end

      {:error, :not_found} ->
        {:noreply,
         socket
         |> assign(error: "Invalid room ID")}
    end
  end

  # Handles the "submit_username" event, validating the username and broadcasting it.
  # Redirects the user to the game view.
  def handle_event("submit_username", %{"username" => username}, socket) do
    if String.trim(username) == "" do
      {:noreply,
       socket
       |> put_flash(:error, "Username cannot be empty")
       |> assign(error: "Username cannot be empty")}
    else
      # Broadcast the username to the response topic
      IslandGameWeb.Endpoint.broadcast("response:#{socket.assigns.room_id}", "user_joined", %{
        username: username,
        joined_at: DateTime.utc_now()
      })

      {:noreply,
       socket
       |> redirect(to: ~p"/game/#{socket.assigns.room_id}/user?username=#{username}")}
    end
  end

  # Handles the "close_modal" event, hiding the username input modal.
  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, show_username_modal: false)}
  end

  # Generates a random 6-digit room ID, padded with leading zeros.
  defp generate_room_id do
    :rand.uniform(999_999)
    |> Integer.to_string()
    |> String.pad_leading(6, "0")
  end
end

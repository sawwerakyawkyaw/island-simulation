defmodule IslandGameWeb.LobbyLive do
  use IslandGameWeb, :live_view
  alias IslandGame.GameServer

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      room_id: nil,
      room_name: nil,
      error: nil
    )}
  end

  def handle_event("create_room", %{"room_name" => room_name}, socket) do
    room_id = generate_room_id()

    case GameServer.create_room(room_id, room_name) do
      {:ok, _room} ->
        {:noreply,
          socket
          |> put_flash(:info, "Room created successfully!")
          |> redirect(to: ~p"/game/#{room_id}/admin")
        }
      {:error, _reason} ->
        {:noreply,
          socket
          |> put_flash(:error, "Failed to create room")
          |> assign(error: "Failed to create room")
        }
    end
  end

  def handle_event("join_room", %{"room_id" => room_id}, socket) do
    case GameServer.get_room(room_id) do
      {:ok, _room} ->
        {:noreply,
          socket
          |> redirect(to: ~p"/game/#{room_id}/user")
        }
      {:error, :not_found} ->
        {:noreply,
          socket
          |> put_flash(:error, "Room not found")
          |> assign(error: "Invalid room ID")
        }
    end
  end

  defp generate_room_id do
    :crypto.strong_rand_bytes(4)
    |> Base.encode16()
    |> String.downcase()
  end
end

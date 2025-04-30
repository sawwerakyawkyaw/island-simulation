defmodule IslandGameWeb.AdminLive do
  use Phoenix.LiveView
  alias IslandGame.GameServer

  @background_colors [
    "rgba(255, 99, 132, 0.2)",
    "rgba(255, 159, 64, 0.2)",
    "rgba(255, 205, 86, 0.2)",
    "rgba(75, 192, 192, 0.2)",
    "rgba(54, 162, 235, 0.2)"
  ]

  @border_colors [
    "rgb(255, 99, 132)",
    "rgb(255, 159, 64)",
    "rgb(255, 205, 86)",
    "rgb(75, 192, 192)",
    "rgb(54, 162, 235)"
  ]

  @impl true
  def mount(%{"game_id" => game_id}, _session, socket) do
    topic = "response:#{game_id}"

    if connected?(socket), do: IslandGameWeb.Endpoint.subscribe(topic)

    {:ok, assign(socket,
      game_id: game_id,
      responses: %{},
      current_round: 0,
      chart_config: %{
        type: "line",
        data: %{
          labels: ~w(Year-0 Year-1 Year-2 Year-3 Year-4 Year-5),
          datasets: [
            %{
              label: "Island Population",
              data: [100, 250, 300, 400, 500, 600],
              backgroundColor: @background_colors,
              borderColor: @border_colors,
              borderWidth: 1
            }
          ]
        },
        options: %{
          scales: %{
            y: %{
              beginAtZero: true
            }
          }
        }
      }
    )}
  end

  @impl true
  def handle_info(%{event: "user_response", payload: response}, socket) do
    updated = Map.update(
      socket.assigns.responses,
      response.user_id,
      [response],
      &(&1 ++ [response])
    )
    {:noreply, assign(socket, :responses, updated)}
  end

  @impl true
  def handle_event("start_round", _params, socket) do
    case GameServer.get_season_for_round(1) do
      nil -> {:noreply, socket}
      %{season: season, yields: yields} ->
        IslandGameWeb.Endpoint.broadcast("game:#{socket.assigns.game_id}", "new_round", %{
          season: season,
          yields: yields,
          round_id: 1
        })

        {:noreply, assign(socket, :current_round, 1)}
    end
  end

  @impl true
  def handle_event("next_round", _params, socket) do
    next_round = socket.assigns.current_round + 1

    case GameServer.get_season_for_round(next_round) do
      nil -> {:noreply, socket}
      %{season: season, yields: yields} ->
        IslandGameWeb.Endpoint.broadcast("game:#{socket.assigns.game_id}", "new_round", %{
          season: season,
          yields: yields,
          round_id: next_round
        })

        {:noreply, assign(socket, :current_round, next_round)}
    end
  end
end

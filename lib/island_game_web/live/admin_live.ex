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

  @round_labels ~w(Round-1 Round-2 Round-3 Round-4 Round-5 Round-6 Round-7 Round-8 Round-9 Round-10)

  @impl true
  def mount(%{"game_id" => game_id}, _session, socket) do
    topic = "response:#{game_id}"

    if connected?(socket), do: IslandGameWeb.Endpoint.subscribe(topic)

    {:ok, assign(socket,
      game_id: game_id,
      responses: %{},
      current_round: 0,
      user_charts: %{}
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

    # Update individual chart configs for each user
    user_charts = Enum.reduce(updated, %{}, fn {user_id, responses}, acc ->
      username = case List.first(responses) do
        %{username: username} when not is_nil(username) -> username
        _ -> "User #{user_id}"
      end

      # Create a map of round_id to population for easier lookup
      population_by_round = Map.new(responses, fn resp -> {resp.round_id, resp.new_population} end)

      # Get populations in order of rounds, defaulting to nil for missing rounds
      populations = Enum.map(1..5, fn round -> Map.get(population_by_round, round) end)

      chart_config = %{
        type: "bar",
        data: %{
          labels: @round_labels,
          datasets: [
            %{
              label: "Population",
              data: populations,
              backgroundColor: Enum.at(@background_colors, rem(user_id, length(@background_colors))),
              borderColor: Enum.at(@border_colors, rem(user_id, length(@border_colors))),
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

      Map.put(acc, user_id, %{username: username, config: chart_config})
    end)

    {:noreply, assign(socket, responses: updated, user_charts: user_charts)}
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

defmodule IslandGameWeb.AdminLive do
  @moduledoc """
  Provides administrative controls and views for managing the game.
  """
  use IslandGameWeb, :live_view
  alias IslandGame.GameServer

  @default_weather_params %{
    mean_temp: 25.0,
    std_dev_temp: 2.0,
    precip_lambda: 1.0,
    threshold: 27
  }

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

  defp generate_round_labels(current_round) do
    1..current_round
    |> Enum.map(&"Round-#{&1}")
  end

  @impl true
  def mount(%{"room_id" => room_id}, _session, socket) do
    topic = "response:#{room_id}"

    if connected?(socket), do: IslandGameWeb.Endpoint.subscribe(topic)

    # Get room information
    room_info =
      case GameServer.get_room(room_id) do
        {:ok, room} -> room
        {:error, _} -> %{id: room_id, name: "Unknown Room"}
      end

    {:ok,
     assign(socket,
       room_id: room_id,
       room_name: room_info.name,
       responses: %{},
       current_round: 0,
       user_charts: %{},
       weather_params: @default_weather_params,
       extreme_event_probability: 20
     )}
  end

  @impl true
  def handle_info(%{event: "user_response", payload: response}, socket) do
    updated =
      Map.update(
        socket.assigns.responses,
        response.user_id,
        [response],
        &(&1 ++ [response])
      )

    # Update individual chart configs for each user
    user_charts =
      Enum.reduce(updated, %{}, fn {user_id, responses}, acc ->
        username =
          case List.first(responses) do
            %{username: username} when not is_nil(username) -> username
            _ -> "User #{user_id}"
          end

        # Create a map of round_id to population for easier lookup
        population_by_round =
          Map.new(responses, fn resp -> {resp.round_id, resp.new_population} end)

        # Get populations in order of rounds, defaulting to nil for missing rounds
        populations =
          Enum.map(1..socket.assigns.current_round, fn round ->
            Map.get(population_by_round, round)
          end)

        chart_config = %{
          type: "bar",
          data: %{
            labels: generate_round_labels(socket.assigns.current_round),
            datasets: [
              %{
                label: "Population",
                data: populations,
                backgroundColor:
                  Enum.at(@background_colors, rem(user_id, length(@background_colors))),
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
  def handle_event(
        "simulate",
        %{
          "mean_temp" => mean,
          "std_dev_temp" => std_dev,
          "precip_lambda" => lambda,
          "threshold" => threshold,
          "extreme_event_probability" => extreme_event_probability
        },
        socket
      ) do
    current_round = socket.assigns.current_round + 1

    # Helper function to safely convert string to float
    to_float = fn str ->
      case Float.parse(str) do
        {float, _} -> float
        :error -> String.to_integer(str) * 1.0
      end
    end

    parsed = {
      to_float.(mean),
      to_float.(std_dev),
      to_float.(lambda),
      String.to_integer(threshold),
      String.to_integer(extreme_event_probability)
    }

    # Update weather params in socket assigns
    updated_weather_params = %{
      mean_temp: elem(parsed, 0),
      std_dev_temp: elem(parsed, 1),
      precip_lambda: elem(parsed, 2),
      threshold: elem(parsed, 3)
    }

    case GameServer.simulate_round(
           elem(parsed, 0),
           elem(parsed, 1),
           elem(parsed, 2),
           elem(parsed, 3),
           elem(parsed, 4)
         ) do
      %{season: season, yields: yields, extreme_event: extreme_event} ->
        IslandGameWeb.Endpoint.broadcast("game:#{socket.assigns.room_id}", "new_round", %{
          season: season,
          yields: yields,
          extreme_event: extreme_event,
          round_id: current_round
        })

        {:noreply,
         socket
         |> assign(:current_round, current_round)
         |> assign(:weather_params, updated_weather_params)
         |> assign(:extreme_event_probability, elem(parsed, 4))}
    end
  end
end

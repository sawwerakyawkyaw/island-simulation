defmodule IslandGameWeb.UserLive do
  use IslandGameWeb, :live_view
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
  def mount(%{"room_id" => room_id, "username" => username}, _session, socket) do
    user_id = Enum.random(1..999)
    topic = "game:#{room_id}"

    if connected?(socket), do: IslandGameWeb.Endpoint.subscribe(topic)

    {:ok,
     socket
     |> assign(:room_id, room_id)
     |> assign(:current_user, %{id: user_id, username: username})
     |> assign(:game_data, nil)
     |> assign(:current_population, 100)
     |> assign(:responses, [])
     |> assign(:chart_config, %{
       type: "bar",
       data: %{
         labels: @round_labels,
         datasets: [
           %{
             label: "Population",
             data: [],
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
     })}
  end

  @impl true
  def handle_info(%{event: "new_round", payload: game_data}, socket) do
    {:noreply, assign(socket, :game_data, game_data)}
  end

  @impl true
  def handle_info({:game_update, game_data}, socket) do
    {:noreply, assign(socket, game_data: game_data)}
  end

  @impl true
  def handle_event("submit_response", %{"fields" => fields}, socket) do
    total_fields =
      fields
      |> Map.values()
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum()

    if total_fields > 4 do
      {:noreply, put_flash(socket, :error, "Total number of fields cannot exceed 4")}
    else
      # Convert string values to integers
      field_choices =
        Enum.reduce(fields, %{}, fn {crop, quantity}, acc ->
          Map.put(acc, crop, String.to_integer(quantity))
        end)

      # Calculate new population
      result =
        GameServer.process_round(
          socket.assigns.game_data.season,
          field_choices,
          socket.assigns.current_population
        )

      # Create response record
      response = %{
        round_id: socket.assigns.game_data.round_id,
        fields: fields,
        total_yield: result.total_yield,
        new_population: result.new_population
      }

      # Update chart data
      updated_responses = [response | socket.assigns.responses]

      population_by_round =
        Map.new(updated_responses, fn resp -> {resp.round_id, resp.new_population} end)

      populations = Enum.map(1..10, fn round -> Map.get(population_by_round, round) end)

      chart_config =
        put_in(socket.assigns.chart_config, [:data, :datasets, Access.at(0), :data], populations)

      # Broadcast the response
      IslandGameWeb.Endpoint.broadcast("response:#{socket.assigns.room_id}", "user_response", %{
        user_id: socket.assigns.current_user.id,
        username: socket.assigns.current_user.username,
        fields: fields,
        round_id: socket.assigns.game_data.round_id,
        total_yield: result.total_yield,
        new_population: result.new_population
      })

      {:noreply,
       socket
       |> assign(:current_population, result.new_population)
       |> assign(:responses, updated_responses)
       |> assign(:chart_config, chart_config)}
    end
  end
end

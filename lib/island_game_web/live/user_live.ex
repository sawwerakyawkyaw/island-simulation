defmodule IslandGameWeb.UserLive do
  use IslandGameWeb, :live_view
  alias IslandGame.GameServer

  @impl true
  def mount(%{"game_id" => game_id}, _session, socket) do
    user_id = Enum.random(1..999)
    topic = "game:#{game_id}"

    if connected?(socket), do: IslandGameWeb.Endpoint.subscribe(topic)

    {:ok,
     socket
     |> assign(:game_id, game_id)
     |> assign(:current_user, %{id: user_id, username: nil})
     |> assign(:game_data, nil)
     |> assign(:current_population, 100)
     |> assign(:responses, [])}
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
  def handle_event("set_username", %{"username" => username}, socket) do
    {:noreply, assign(socket, :current_user, %{id: socket.assigns.current_user.id, username: username})}
  end

  @impl true
  def handle_event("submit_response", %{"fields" => fields}, socket) do
    total_fields = fields
    |> Map.values()
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()

    if total_fields > 4 do
      {:noreply, put_flash(socket, :error, "Total number of fields cannot exceed 4")}
    else
      # Convert string values to integers
      field_choices = Enum.reduce(fields, %{}, fn {crop, quantity}, acc ->
        Map.put(acc, crop, String.to_integer(quantity))
      end)

      # Calculate new population
      result = GameServer.process_round(
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

      # Broadcast the response
      IslandGameWeb.Endpoint.broadcast("response:#{socket.assigns.game_id}", "user_response", %{
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
       |> assign(:responses, [response | socket.assigns.responses])}
    end
  end

end

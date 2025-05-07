defmodule IslandGame.GameServer do
  @moduledoc """
  A context module for handling game-related operations like season generation. Calculating the total yield and updating the population.
  """

  use GenServer

  @yields %{
    "Wet/Cool" => %{
      "Wecool Rice" => 100,
      "Wot Rice" => 50,
      "Drool Beans" => 50,
      "Dot Beans" => 25
    },
    "Wet/Hot" => %{
      "Wecool Rice" => 50,
      "Wot Rice" => 100,
      "Drool Beans" => 25,
      "Dot Beans" => 50
    },
    "Dry/Cool" => %{
      "Wecool Rice" => 50,
      "Wot Rice" => 25,
      "Drool Beans" => 100,
      "Dot Beans" => 50
    },
    "Dry/Hot" => %{
      "Wecool Rice" => 25,
      "Wot Rice" => 50,
      "Drool Beans" => 50,
      "Dot Beans" => 100
    }
  }

  @extreme_events %{
    # 25% - Yearly yield drop
    1 => "Root Rot",
    # 25% - Yearly yield drop
    2 => "Drought",
    # 100% - Wecool Rice yield drop
    3 => "Virus",
    # 25% - Yearly yield drop
    4 => "Late Frost",
    # 25% - Yearly yield drop
    5 => "Heat Wave"
  }

  @doc """
  Generates a season based on temperature and precipitation parameters.
  Returns a map containing the season string and its corresponding yields.
  """
  def simulate_round(mean_temp, std_dev_temp, lambda, threshold, extreme_event_probability) do
    temp_value = gaussian(mean_temp, std_dev_temp)
    precipitation_value = exponential(lambda)
    extreme_event = gaussian_random_event(extreme_event_probability)

    temperature = if temp_value > threshold, do: "Hot", else: "Cool"
    precipitation = if precipitation_value < 0.5, do: "Dry", else: "Wet"

    season = "#{precipitation}/#{temperature}"
    %{season: season, yields: @yields[season], extreme_event: extreme_event}
  end

  @doc """
  Calculates the total yield based on the user's field choices for a given season.

  ## Parameters
    - season: The current season (e.g., "Wet/Cool")
    - field_choices: A map of crop names to quantities planted (e.g., %{"Wecool Rice" => 2, "Wot Rice" => 2})

  ## Returns
    The total yield as an integer
  """
  def calculate_total_yield(season, field_choices) do
    season_yields = @yields[season]

    Enum.reduce(field_choices, 0, fn {crop, quantity}, acc ->
      yield = season_yields[crop] || 0
      acc + yield * quantity
    end)
  end

  @doc """
  Updates the population based on the total yield and current population.

  ## Parameters
    - total_yield: The total yield from the season
    - current_population: The current population (defaults to 100)

  ## Returns
    The new population as an integer
  """
  def update_population(total_yield, current_population \\ 100) do
    surplus = total_yield - current_population

    if surplus > 0 do
      current_population + div(surplus, 2)
    else
      total_yield
    end
  end

  @doc """
  Processes a round by calculating the total yield and updating the population.

  ## Parameters
    - season: The current season
    - field_choices: A map of crop names to quantities planted
    - extreme_event: The extreme event tuple or :no_event atom
    - current_population: The current population (defaults to 100)

  ## Returns
    A map containing:
      - total_yield: The calculated total yield
      - new_population: The updated population
  """
  def process_round(season, field_choices, has_extreme_event, current_population \\ 100) do
    total_yield = calculate_total_yield(season, field_choices)
    adjusted_yield = if has_extreme_event, do: trunc(total_yield * 0.75), else: total_yield
    new_population = update_population(adjusted_yield, current_population)

    %{
      total_yield: adjusted_yield,
      new_population: new_population
    }
  end

  # Client API
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Creates a new game room with the given ID and name.
  """
  def create_room(room_id, room_name) do
    GenServer.call(__MODULE__, {:create_room, room_id, room_name})
  end

  @doc """
  Retrieves a room by its ID.
  """
  def get_room(room_id) do
    GenServer.call(__MODULE__, {:get_room, room_id})
  end

  @doc """
  Starts the game for a given room ID.
  Returns {:ok, room} if successful, {:error, reason} if not.
  """
  def start_game(room_id) do
    GenServer.call(__MODULE__, {:start_game, room_id})
  end

  @doc """
  Checks if a game has started for a given room ID.
  Returns true if the game has started, false otherwise.
  """
  def game_started?(room_id) do
    GenServer.call(__MODULE__, {:game_started?, room_id})
  end

  # Server Callbacks
  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:create_room, room_id, room_name}, _from, rooms) do
    if Map.has_key?(rooms, room_id) do
      {:reply, {:error, :room_exists}, rooms}
    else
      new_room = %{
        id: room_id,
        name: room_name,
        created_at: DateTime.utc_now(),
        game_started: false,
        players: [],
        state: %{
          current_round: 1,
          population: 100,
          field_choices: %{},
          history: []
        }
      }

      {:reply, {:ok, new_room}, Map.put(rooms, room_id, new_room)}
    end
  end

  def handle_call({:get_room, room_id}, _from, rooms) do
    case Map.get(rooms, room_id) do
      nil -> {:reply, {:error, :not_found}, rooms}
      room -> {:reply, {:ok, room}, rooms}
    end
  end

  def handle_call({:start_game, room_id}, _from, rooms) do
    case Map.get(rooms, room_id) do
      nil ->
        {:reply, {:error, :not_found}, rooms}

      room ->
        if room.game_started do
          {:reply, {:error, :game_already_started}, rooms}
        else
          updated_room = Map.put(room, :game_started, true)
          updated_rooms = Map.put(rooms, room_id, updated_room)
          {:reply, {:ok, updated_room}, updated_rooms}
        end
    end
  end

  def handle_call({:game_started?, room_id}, _from, rooms) do
    case Map.get(rooms, room_id) do
      nil -> {:reply, {:error, :not_found}, rooms}
      room -> {:reply, {:ok, room.game_started}, rooms}
    end
  end

  defp gaussian(mean, std_dev) do
    x = :rand.uniform()
    y = :rand.uniform()
    z = :math.sqrt(-2 * :math.log(x)) * :math.cos(2 * :math.pi() * y)
    z * std_dev + mean
  end

  defp exponential(lambda) when lambda > 0 do
    -:math.log(1 - :rand.uniform()) / lambda
  end

  # Use :rand.normal/2 → mean and std dev
  defp gaussian_random_event(probability) do
    # Centered at slider value, e.g., 0–100
    mean = probability
    # You can tweak this to adjust spread
    std_dev = 15

    value = :rand.normal(mean, std_dev) |> Float.round() |> trunc
    value = max(min(value, 100), 0)

    if value > 60 do
      # Pick a random event from the map
      {:extreme_event, Enum.random(Map.values(@extreme_events))}
    else
      {:no_event}
    end
  end
end

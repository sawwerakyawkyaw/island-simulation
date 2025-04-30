defmodule IslandGame.GameServer do
  @moduledoc """
  A context module for handling game-related operations like season generation.
  """

  @seasons [
    "Wet/Cool",
    "Wet/Hot",
    "Dry/Cool",
    "Dry/Hot"
  ]

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

  # Generate 10 random seasons by selecting from the 4 possible seasons
  @random_seasons Enum.map(1..10, fn _ -> Enum.random(@seasons) end)

  @doc """
  Returns a list of all available seasons.
  """
  def get_seasons, do: @seasons

  @doc """
  Returns the list of randomly generated seasons for the game.
  """
  def get_random_seasons, do: @random_seasons

  @doc """
  Gets a season and its yields for a specific round.
  Returns nil if the round is out of bounds.
  """
  def get_season_for_round(round) when is_integer(round) and round > 0 and round <= 10 do
    case Enum.at(@random_seasons, round - 1) do
      nil -> nil
      season -> %{season: season, yields: @yields[season]}
    end
  end

  def get_season_for_round(_), do: nil

  @doc """
  Gets the next season and its yields based on the current round.
  Returns nil if there are no more seasons.
  """
  def get_next_season(current_round) when is_integer(current_round) do
    get_season_for_round(current_round + 1)
  end

  def get_next_season(_), do: nil

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
      acc + (yield * quantity)
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
    - current_population: The current population (defaults to 100)

  ## Returns
    A map containing:
      - total_yield: The calculated total yield
      - new_population: The updated population
  """
  def process_round(season, field_choices, current_population \\ 100) do
    total_yield = calculate_total_yield(season, field_choices)
    new_population = update_population(total_yield, current_population)

    %{
      total_yield: total_yield,
      new_population: new_population
    }
  end
end

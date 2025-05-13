defmodule IslandGameWeb.TestLive do
  @moduledoc """
  A LiveView for testing various UI components and game interactions.
  """
  use IslandGameWeb, :live_view

  @background_colors [
    "rgb(255, 0, 0)",
    "rgb(0, 255, 0)",
    "rgb(0, 0, 255)",
    "rgb(255, 0, 255)"
  ]

  @border_colors [
    "rgb(0, 0, 0)"
  ]

  @crop_history_data [
    %{
      label: "Wecool Rice",
      data: [0, 2, 1, 4, 3],
      borderColor: "rgb(225, 0, 0)",
      backgroundColor: "rgb(225, 101, 101)",
      borderWidth: 1
    },
    %{
      label: "Wot Rice",
      data: [4, 0, 2, 1, 3],
      borderColor: @border_colors,
      backgroundColor: "rgb(101, 255, 101)",
      borderWidth: 1
    },
    %{
      label: "Drool Bean",
      data: [4, 0, 2, 1, 3],
      borderColor: @border_colors,
      backgroundColor: "rgb(0, 0, 255)",
      borderWidth: 1
    },
    %{
      label: "Dot Bean",
      data: [4, 0, 2, 1, 3],
      borderColor: @border_colors,
      backgroundColor: "rgb(255, 0, 255)",
      borderWidth: 1
    }
  ]

  @doc """
  Mounts the TestLive view and assigns initial chart configurations.
  """
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       config: config(1),
       crop_history: crop_history(1),
       weather_trend: weather_trend(1)
     )}
  end

  # Returns the configuration for the island population chart.
  defp config(1) do
    %{
      type: "line",
      data: %{
        labels: ~w(January February March April May June July),
        datasets: [
          %{
            label: "Island Population",
            data: [65, 59, 80, 81, 56, 55, 40],
            backgroundColor: @background_colors,
            borderColor: @border_colors,
            borderWidth: 4
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
  end


  # Returns the configuration for the crop history chart.
  defp crop_history(1) do
    %{
      type: "bar",
      data: %{
        labels: ~w(January February March April May June July),
        datasets: @crop_history_data
      },
      options: %{
        scales: %{
          y: %{
            beginAtZero: true
          }
        },
        plugins: %{
          legend: %{
            display: true
          }
        }
      }
    }
  end

  # Returns the configuration for the weather trend chart.
  defp weather_trend(1) do
    %{
      type: "line",
      data: %{
        labels: ~w(January February March April May June July),
        datasets: [
          %{
            label: "Island Population",
            data: [65, 59, 80, 81, 56, 55, 40],
            backgroundColor: @background_colors,
            borderColor: @border_colors,
            borderWidth: 4
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
  end
end

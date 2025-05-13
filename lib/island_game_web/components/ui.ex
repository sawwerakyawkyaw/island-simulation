defmodule IslandGameWeb.Components.UI do
  @moduledoc """
  Provides UI components for the Island Game.
  """
  defmacro __using__(_opts) do
    quote do
      import IslandGameWeb.Components.UI.{
        Navbar,
        Footer
      }
    end
  end
end

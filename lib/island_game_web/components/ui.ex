defmodule IslandGameWeb.Components.UI do
  defmacro __using__(_opts) do
    quote do
      import IslandGameWeb.Components.UI.{
        Navbar
      }
    end
  end
end

defmodule IslandGameWeb.TestLive do
  use IslandGameWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

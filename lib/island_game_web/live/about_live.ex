defmodule IslandGameWeb.AboutLive do
  @moduledoc """
  LiveView for the About page.
  """
  use IslandGameWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

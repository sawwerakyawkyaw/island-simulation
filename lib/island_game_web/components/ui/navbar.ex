defmodule IslandGameWeb.Components.UI.Navbar do
  use Phoenix.Component

  @doc """
  Renders a navbar.

  ## Examples
    <.navbar/>
  """

  def navbar(assigns) do
    ~H"""
    <nav class="fixed top-0 w-full bg-white/30 backdrop-blur-md border-b border-gray-200/20 z-30 transition-all duration-300">
      <div class="max-w-5xl mx-auto px-4 flex items-center justify-between h-16">
        <a class="flex flex-row items-center gap-2 font-display text-2xl" href="/home">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="lucide lucide-mountain-snow-icon lucide-mountain-snow"
          >
            <path d="m8 3 4 8 5-5 5 15H2L8 3z" />
            <path d="M4.14 15.08c2.62-1.57 5.24-1.43 7.86.42 2.74 1.94 5.49 2 8.23.19" />
          </svg>
          <span class="font-normal">Island Sims</span>
        </a>
      </div>
    </nav>
    """
  end
end

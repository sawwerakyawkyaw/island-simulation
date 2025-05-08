defmodule IslandGameWeb.Components.UI.Footer do
  use Phoenix.Component

  def footer(assigns) do
    ~H"""
    <footer class="text-center max-w-sm md:max-w-full mx-auto mb-6">
      <p class="text-xs md:text-sm text-gray-500">
        crafted by<!-- -->
        <a
          class="text-gray-950 hover:text-teal-500 hover:no-underline hover:font-bold transition-all duration-300 ease-in-out underline underline-offset-4 decoration-indigo-700 decoration-2"
          target="_blank"
          rel="noopener noreferrer"
          href="https://sawwerakyawkyaw.com"
        >
          Saw Wera Kyaw Kyaw
        </a>
        & <a
          class="text-gray-950 hover:text-teal-500 hover:no-underline hover:font-bold transition-all duration-300 ease-in-out underline underline-offset-4 decoration-indigo-700 decoration-2"
          target="_blank"
          rel="noopener noreferrer"
          href=""
        >Sarah Maldonado</a>&nbsp;·&nbsp; <a
          class="text-gray-950 hover:text-teal-500 hover:font-bold transition-all duration-300 ease-in-out"
          target="_blank"
          rel="noopener noreferrer"
          href="https://github.com/sawwerakyawkyaw/island-simulation"
        >github</a>&nbsp;·&nbsp;
        <a
          class="text-gray-950 hover:text-teal-500 hover:font-bold transition-all duration-300 ease-in-out"
          href="/about"
        >
          about this site
        </a>
      </p>
    </footer>
    """
  end
end

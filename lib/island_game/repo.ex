defmodule IslandGame.Repo do
  use Ecto.Repo,
    otp_app: :island_game,
    adapter: Ecto.Adapters.Postgres
end

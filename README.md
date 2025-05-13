# IslandGame

This project is built with the Elixir language, Phoenix LiveView, and Tailwind CSS.

## Tech Stack

- **Elixir & Phoenix**
- **Phoenix LiveView**
- **Tailwind CSS**
- **Custom JS Hooks**

## User Manual

### Local development for future iterations

### Prerequisites

Before you begin, ensure you have the following installed:

- **Elixir and Erlang:**
  - Elixir v1.17+ requires Erlang/OTP 26.0 or later.
  - The recommended way to install Elixir and Erlang is by using a version manager like `asdf`.
    - Install `asdf`: Follow the instructions on the [asdf official website](https://asdf-vm.com/guide/getting-started.html).
    - Add Elixir and Erlang plugins:
      ```bash
      asdf plugin add elixir
      asdf plugin add erlang
      ```
    - Install specific versions (check the `.tool-versions` file in this project for the exact versions, or use the latest stable ones if starting fresh):
      ```bash
      asdf install erlang <latest_stable_erlang_version>
      asdf install elixir <latest_stable_elixir_version>
      asdf global erlang <latest_stable_erlang_version>
      asdf global elixir <latest_stable_elixir_version>
      ```
  - Alternatively, follow the official installation instructions on the [Elixir Lang website](https://elixir-lang.org/install.html). For macOS, Homebrew is a common option:
    ```bash
    brew install elixir
    ```

### Project Setup

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies.
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

### Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix

### Game Guide

This guide explains how to interact with the IslandGame.

### For Administrators (Hosts)

1.  **Creating a Room:**

    - If you want to play IslandGame as an admin (host), please create the room.
    - On the ladning page, you will see the create room form and give the room a name, this will generate an id for the players to join.
    - Click on "Create Room".
    - The lobby area will be redirected and allow you to wait for the players to join

2.  **Starting the Game/Simulation:**
    - Once the room is created, wait for they players to join and once players have joined, you can start the game or simulation rounds from the admin interface.


3.  **Adjusting Simulation Parameters:**

    - Once you have started the game, you can adjust the parameters for reach round to simulate.

### For Users (Players)

1.  **Joining a Game Room:**

    - To join a game, you will need a Room ID.
    - The Room ID will be provided by the administrator or another player who has created/joined the room.
    - On the game's main page or a designated "Join Game" page, enter the Room ID into the specified field.
    - Click "Join" or a similar button.

2.  **Playing the Game:**
    - Once you've joined a room, you will be part of the simulation.
    - Wait until the admin reveal the seasonal pattern and start interacting with the game.
    - Follow the on-screen instructions and game rules to participate.

class BuildGameState
  attr_reader :game, :errors

  def initialize(game)
    @game = game
    @errors = []
  end

  def call
    player_turns_and_colours.inject(base_state) do |current_game_state, (player, steps)|
      service = TakeTurn.new(game_state: current_game_state, player: player, steps: steps)
      service.call

      @errors += service.errors

      service.game_state
    end
  end

  private

  def player_turns_and_colours
    game.steps.ordered.chunk(&:player).map do |player, steps|
      [player, steps]
    end
  end

  def base_state
    GameState.new(game, starting_board, red_player)
  end

  def starting_board
    red_occupied = (1..12).to_a.map { |number| [number, "red"]  }
    empty = (13..20).to_a.map { |number| [number, "empty"]  }
    white_occupied = (21..32).to_a.map { |number| [number, "white"]  }

    Board.new(red_occupied + empty + white_occupied)
  end

  def red_player
    game.players.find { |player| player.colour == "red" }
  end
end

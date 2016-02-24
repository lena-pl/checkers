class BuildGameState
  attr_reader :game, :errors
  ORIGINAL_RED_PIECES_32_SQUARE_BOARD = (1..12).to_a
  ORIGINAL_EMPTY_SQUARES_32_SQUARE_BOARD = (13..20).to_a
  ORIGINAL_WHITE_PIECES_32_SQUARE_BOARD = (21..32).to_a

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
    red_occupied = ORIGINAL_RED_PIECES_32_SQUARE_BOARD.map { |number| [number, "red"]  }
    empty = ORIGINAL_EMPTY_SQUARES_32_SQUARE_BOARD.map { |number| [number, "empty"]  }
    white_occupied = ORIGINAL_WHITE_PIECES_32_SQUARE_BOARD.map { |number| [number, "white"]  }

    Board.new(red_occupied + empty + white_occupied)
  end

  def red_player
    game.players.find { |player| player.colour == "red" }
  end
end

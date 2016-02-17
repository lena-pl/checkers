class BuildGameState
  def initialize(game)
    @game = game
    @errors = []
  end

  def call
    player_turns_and_colours.inject(base_state) do |current_game_state, player_steps|
      service = TakeTurn.new(game_state: current_game_state, player_colour: player_steps[0], steps: player_steps[1])
      service.call

      puts "BUILD GAME STATE LOOP"
      puts "CURRENT CHUNK: #{player_steps}"
      puts "++++++++++++++++++++++++++++++"

      @errors += service.errors
      service.game_state
    end
  end

  private

  def player_turns_and_colours
    all_steps = @game.steps.order(:id)
    chunks = []

    all_steps.chunk do |step|
      step.player == red_player
    end.each do |red_player, steps|
      chunks.push [red_player, steps]
    end

    turn_steps(chunks)
  end

  def turn_steps(chunks)
    chunks.map do |chunk|
      if chunk[0] == true
        chunk[0] = "red"
        chunk
      elsif chunk[0] == false
        chunk[0] = "white"
        chunk
      end
    end
  end

  def base_state
    GameState.new(@game, starting_board, red_player)
  end

  def starting_board
    red_occupied = (1..12).to_a.map { |number| [number, "red"]  }
    empty = (13..20).to_a.map { |number| [number, "empty"]  }
    white_occupied = (21..32).to_a.map { |number| [number, "white"]  }

    Board.new(red_occupied + empty + white_occupied)
  end

  def red_player
    @game.players.find { |player| player.colour == "red" }
  end
end

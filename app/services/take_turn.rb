class TakeTurn
  attr_reader :errors, :game_state

  def initialize(game_state:, player_colour:, steps:)
    @game_state = game_state
    @steps = steps
    @player = game_state.game.players.find { |player| player.colour == player_colour }
    @board = game_state.board
    @errors = []
  end

  def call
    if player_allowed_to_move?
      @board = apply_steps

      puts "TAKE TURN"
      puts "last step id: #{@steps.last.id}"
      puts "last step kind: #{@steps.last.kind}"
      puts "========="

      @errors.push "You must make all available jumps to complete your turn" if @steps.last.kind == "jump" && more_pieces_can_be_captured?
      find_next_player if @errors.empty?
    else
      @errors.push "It's not your turn right now!"
    end

    @errors.uniq

    @game_state
  end

  private

  def player_allowed_to_move?
    @game_state.current_player == @player
  end

  def apply_steps
    @steps.inject(@board) do |current_board, step|
      service = ApplyStep.new(current_board, step)
      service.call

      @errors + service.errors
      service.board
    end
  end

  def more_pieces_can_be_captured?
    final_destination_square = @board.square_by_position(@steps.last.to)
    original_x = @board.x_coord(final_destination_square)
    original_y = @board.y_coord(final_destination_square)

    puts "NEW CHECK"
    puts "player colour: #{@player.colour}"
    puts "destination square: #{final_destination_square}"
    potential_enemy_square_y = change_y_coord(original_y)
    left_square = @board.square_by_coordinates(original_x - 1, potential_enemy_square_y)
    puts "left square: #{left_square}"
    right_square = @board.square_by_coordinates(original_x + 1, potential_enemy_square_y)
    puts "right square: #{right_square}"
    puts "=========="

    left_square_has_jumpable_enemy(left_square, enemy_colour, potential_enemy_square_y) || right_square_has_jumpable_enemy(right_square, enemy_colour, potential_enemy_square_y)
  end

  def left_square_has_jumpable_enemy(left_square, enemy_colour, potential_enemy_square_y)
    if left_square == nil
      false
    elsif left_square.occupant == enemy_colour
      potential_empty_square_y = change_y_coord(potential_enemy_square_y)
      potential_empty_square = @board.square_by_coordinates(@board.x_coord(left_square) - 1, potential_empty_square_y)

      potential_empty_square.occupant == "empty"
    else
      false
    end
  end

  def right_square_has_jumpable_enemy(right_square, enemy_colour, potential_enemy_square_y)
    if right_square == nil
      false
    elsif right_square.occupant == enemy_colour
      potential_empty_square_y = change_y_coord(potential_enemy_square_y)
      potential_empty_square = @board.square_by_coordinates(@board.x_coord(right_square) + 1, potential_empty_square_y)

      potential_empty_square.occupant == "empty"
    else
      false
    end
  end

  def change_y_coord(y_coord)
    case @player.colour
    when "red"
      y_coord -= 1
    when "white"
      y_coord += 1
    else
      raise ArgumentError
    end
  end

  def enemy_colour
    case @player.colour
    when "red"
      "white"
    when "white"
      "red"
    else
      raise ArgumentError
    end
  end

  def find_next_player
    @game_state.current_player = @game_state.game.players.find { |player| player != @player }
  end
end

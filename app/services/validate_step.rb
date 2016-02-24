class ValidateStep
  attr_reader :errors, :board, :step

  delegate :player, :from, :to, to: :step
  delegate :enemy_colour, to: :player

  def initialize(board, step)
    @step = step
    @board = board
    @errors = []
  end

  def call
    step.simple? ? can_complete_simple_move? : can_complete_jump_move?
  end

  private

  def can_complete_simple_move?
    errors.push "You can only move diagonally!" if !squares_adjacent?
    errors.push "You can only move forward!" if !correct_direction?
    errors.push "That square is occupied!" if !destination_empty?

    errors.empty?
  end

  def can_complete_jump_move?
    errors.push "You can only move forward!" if !correct_direction?
    errors.push "That is not a valid jump path!" if !valid_jump_path?

    errors.empty?
  end

  def destination_empty?
    board.square_occupant(to) == "empty"
  end

  def squares_adjacent?
    board.square_connections(from).include? to
  end

  def valid_jump_path?
    board.shared_piece_position(from, to).present? &&
      board.square_occupant(board.shared_piece_position(from, to)) == enemy_colour &&
       board.square_occupant(to) == "empty"
  end

  def correct_direction?
    player.red? ? from < to : from > to
  end
end

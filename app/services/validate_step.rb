class ValidateStep
  attr_reader :errors, :board, :player, :step

  delegate :from, :to, to: :step
  delegate :enemy_colour, to: :player

  def initialize(board, player, step)
    @board = board
    @player = player
    @step = step
    @errors = []
  end

  def call
    piece_belongs_to_player? && (step.simple? ? can_complete_simple_move? : can_complete_jump_move?)
  end

  private

  def piece_belongs_to_player?
    errors.push "That square doesn't hold one of your pieces!" if board.square_occupant(from).colour != player.colour

    errors.empty?
  end

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
    board.square_occupant(to).nil?
  end

  def squares_adjacent?
    board.square_connections(from).include? to
  end

  def valid_jump_path?
    board.shared_piece_position(from, to).present? &&
      !board.square_occupant(board.shared_piece_position(from, to)).nil? &&
        board.square_occupant(board.shared_piece_position(from, to)).colour == enemy_colour &&
         board.square_occupant(to).nil?
  end

  def correct_direction?
    (board.square_occupant(from).rank == "king") || (step.player.red? ? from < to : from > to)
  end
end

class AvailableJumpDestinations
  attr_reader :errors, :board, :player, :position

  delegate :enemy_colour, to: :player

  def initialize(board, player, position)
    @board = board
    @player = player
    @position = position
    @errors = []
  end

  def call
    valid_destinations || []
  end

  private

  def valid_destinations
    board_positions = board.square_jump_connections(position)

    board_positions.map do |destination|
      destination if can_complete_jump_move?(destination)
    end.compact
  end

  def can_complete_jump_move?(to)
    correct_direction?(to) && valid_jump_path?(to)
  end

  def destination_empty?(to)
    board.square_occupant(to).nil?
  end

  def valid_jump_path?(to)
    enemy_present?(to) && destination_empty?(to)
  end

  def correct_direction?(to)
    (board.square_occupant(position).rank == "king") || (player.red? ? position < to : position > to)
  end

  def enemy_present?(to)
    board.shared_piece_position(position, to).present? &&
      !board.square_occupant(board.shared_piece_position(position, to)).nil? &&
        board.square_occupant(board.shared_piece_position(position, to)).colour == enemy_colour
  end
end

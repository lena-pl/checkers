class AvailableDestinations
  attr_reader :errors, :board, :player, :position

  delegate :enemy_colour, to: :player

  def initialize(board, player, position)
    @board = board
    @player = player
    @position = position
    @errors = []
  end

  def call
    piece_belongs_to_player? ? valid_destinations : []
  end

  private

  def valid_destinations
    board_positions = (1..32).to_a

    board_positions.map do |destination|
      if (squares_adjacent?(destination) ? can_complete_simple_move?(destination) : can_complete_jump_move?(destination))
        destination
      end
    end.compact
  end

  def piece_belongs_to_player?
    errors.push "That square doesn't hold one of your pieces!" if !board.square_occupant(position) || (board.square_occupant(position).colour != player.colour)

    errors.empty?
  end

  def can_complete_simple_move?(to)
    correct_direction?(to) && destination_empty?(to)
  end

  def can_complete_jump_move?(to)
    correct_direction?(to) && valid_jump_path?(to)
  end

  def destination_empty?(to)
    board.square_occupant(to).nil?
  end

  def squares_adjacent?(to)
    board.square_simple_connections(position).include? to
  end

  def valid_jump_path?(to)
    board.shared_piece_position(position, to).present? &&
      !board.square_occupant(board.shared_piece_position(position, to)).nil? &&
        board.square_occupant(board.shared_piece_position(position, to)).colour == enemy_colour &&
         board.square_occupant(to).nil?
  end

  def correct_direction?(to)
    (board.square_occupant(position).rank == "king") || (player.red? ? position < to : position > to)
  end
end

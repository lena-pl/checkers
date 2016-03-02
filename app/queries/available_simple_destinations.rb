class AvailableSimpleDestinations
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
    board_positions = board.square_simple_connections(position)

    board_positions.map do |destination|
      destination if can_complete_simple_move?(destination)
    end.compact
  end

  def can_complete_simple_move?(to)
    correct_direction?(to) && destination_empty?(to)
  end

  def destination_empty?(to)
    board.square_occupant(to).nil?
  end

  def correct_direction?(to)
    (board.square_occupant(position).rank == "king") || (player.red? ? position < to : position > to)
  end
end

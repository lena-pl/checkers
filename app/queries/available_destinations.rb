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
    AvailableSimpleDestinations.new(board, player, position).call + AvailableJumpDestinations.new(board, player, position).call
  end
end

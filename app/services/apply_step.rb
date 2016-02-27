class ApplyStep
  attr_reader :board, :step

  delegate :player, :from, :to, to: :step
  delegate :enemy_colour, to: :player

  def initialize(board, step)
    @step = step
    @board = board
  end

  def call
    board.move_piece(from, to)
    board.capture_piece(board.shared_piece_position(from, to)) if step.jump?

    board
  end
end

class ApplyStep
  attr_reader :errors, :board

  def initialize(board, step)
    @step = step
    @board = board
    @from_square = @board.square_by_position(step.from)
    @to_square = @board.square_by_position(step.to)
    @errors = []
  end

  def call
    if rules_pass?(@step.kind)
      @to_square.occupant = @from_square.occupant
      @from_square.occupant = "empty"

      capture_piece if @step.kind == "jump"
    end

    @board
  end

  private

  def capture_piece
    captured_x_coord_difference = (@board.x_coord(@from_square) - @board.x_coord(@to_square)) / 2
    captured_y_coord_difference = (@board.y_coord(@from_square) - @board.y_coord(@to_square)) / 2

    captured_x_coord = @board.x_coord(@from_square) + captured_x_coord_difference
    captured_y_coord = @board.y_coord(@from_square) + captured_y_coord_difference

    captured_piece = @board.square_by_coordinates(captured_x_coord, captured_y_coord)

    captured_piece.occupant = "empty"
  end

  def rules_pass?(step_kind)
    @errors.push "You can only move diagonally!" if !diagonal_move?
    @errors.push "You can only move forward!" if !correct_direction?
    @errors.push "You can't pass that amount of squares for this type of move!" if !correct_amount_of_squares_passed?(step_kind)

    @errors.empty?
  end

  def diagonal_move?
    number_of_cols_moved = (@board.x_coord(@from_square) - @board.x_coord(@to_square)).abs
    number_of_rows_moved = (@board.y_coord(@from_square) - @board.y_coord(@to_square)).abs

    number_of_rows_moved == number_of_cols_moved
  end

  def correct_amount_of_squares_passed?(step_kind)
    number_of_cols_moved = (@board.x_coord(@from_square) - @board.x_coord(@to_square)).abs

    if step_kind == "simple"
      number_of_cols_moved == 1
    elsif step_kind == "jump"
      number_of_cols_moved == 2
    else
      raise ArgumentError
    end
  end

  def correct_direction?
    row_difference = @board.y_coord(@from_square) - @board.y_coord(@to_square)

    case @step.player.colour
    when "red"
      row_difference > 0
    when "white"
      row_difference < 0
    else
      raise ArgumentError
    end
  end
end

class ApplyStep
  attr_reader :errors, :board

  def initialize(board, step)
    @step = step
    @board = board
    @errors = []
  end

  def call
    if rules_pass?
      @board.move_piece(@step.from, @step.to)

      @board.capture_piece(shared_piece_position(@step.from, @step.to)) if @step.kind == "jump"
    end

    @board
  end

  private

  def rules_pass?
    case @step.kind
    when "simple"
      can_complete_simple_move?
    when "jump"
      can_complete_jump_move?
    end
  end

  def can_complete_simple_move?
    @errors.push "You can only move diagonally!" if !node_adjacent?(@step.from, @step.to)
    @errors.push "You can only move forward!" if !correct_direction?
    @errors.push "That square is occupied!" if !destination_empty?

    @errors.empty?
  end

  def can_complete_jump_move?
    @errors.push "You can only move forward!" if !correct_direction?
    @errors.push "That is not a valid jump path!" if !valid_jump_path?(@step.from, @step.to)

    @errors.empty?
  end

  def destination_empty?
    @board.square_occupant(@step.to) == "empty"
  end

  def node_adjacent?(from, to)
    @board.square_connections(from).include? to
  end

  def valid_jump_path?(from, to)
    shared_piece_position(from, to).present? &&
      @board.square_occupant(shared_piece_position(from, to)) == enemy_colour &&
       @board.square_occupant(to) == "empty"
  end

  def shared_piece_position(from, to)
    (@board.square_connections(from) & @board.square_connections(to)).first
  end

  def correct_direction?
    case @step.player.colour
    when "red"
      @step.from < @step.to
    when "white"
      @step.from > @step.to
    end
  end

  def enemy_colour
    @step.player.colour == "red" ? "white" : "red"
  end
end

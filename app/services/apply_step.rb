class ApplyStep
  attr_reader :errors, :board

  def initialize(board, step)
    @step = step
    @board = board
    @errors = []
  end

  def call
    puts "******************"
    puts "APPLY STEP HAS BEEN CALLED"

    if rules_pass?
      puts "APPLY STEP RULES PASS"
      puts "from_square position: #{@step.from} | old from_square occupant: #{@board.square_occupant(@step.from)}"
      puts "to_square position: #{@step.to} | old to_square occupant: #{@board.square_occupant(@step.to)}"

      @board.move_piece(@step.from, @step.to)

      @board.capture_piece(shared_piece_position(@step.from, @step.to)) if @step.kind == "jump"
    end

    puts "BOARD SHOULD HAVE BEEN UPDATED NOW"
    puts "from_square position: #{@step.from} | new from_square occupant: #{@board.square_occupant(@step.from)}"
    puts "to_square position: #{@step.to} | new to_square occupant: #{@board.square_occupant(@step.to)}"
    puts "BOARD UPDATE ENDS"
    @board
  end

  private

  def rules_pass?
    case @step.kind
    when "simple"
      can_complete_simple_move?
    when "jump"
      can_complete_jump_move?
    else
      raise ArgumentError
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
    else
      raise ArgumentError
    end
  end

  def enemy_colour
    case @step.player.colour
    when "red"
      "white"
    when "white"
      "red"
    else
      raise ArgumentError
    end
  end
end

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
    puts "******************"
    puts "APPLY STEP HAS BEEN CALLED"
    puts "from_square: #{@from_square.inspect}"
    puts "to_square: #{@to_square.inspect}"
    if rules_pass?
      puts "APPLY STEP RULES PASS"
      puts "from_square position: #{@from_square.position} | old from_square occupant: #{@from_square.occupant}"
      puts "to_square position: #{@to_square.position} | old to_square occupant: #{@to_square.occupant}"

      @to_square.occupant = @from_square.occupant
      @from_square.occupant = "empty"

      capture_piece if @step.kind == "jump"
    end

    puts "BOARD SHOULD HAVE BEEN UPDATED NOW"
    puts "from_square position: #{@from_square.position} | new from_square occupant: #{@board.square_by_position(@step.from).occupant}"
    puts "to_square position: #{@to_square.position} | new to_square occupant: #{@board.square_by_position(@step.to).occupant}"
    puts "BOARD UPDATE ENDS"
    @board
  end

  private

  def capture_piece
    captured_piece = shared_node(@from_square, @to_square)

    captured_piece.occupant = "empty"
  end

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
    @errors.push "You can only move diagonally!" if !node_adjacent?(@from_square, @to_square)
    @errors.push "You can only move forward!" if !correct_direction?
    @errors.push "That square is occupied!" if !destination_empty?

    @errors.empty?
  end

  def can_complete_jump_move?
    @errors.push "You can only move forward!" if !correct_direction?
    @errors.push "That is not a valid jump path!" if !valid_jump_path?(@from_square, @to_square)

    @errors.empty?
  end

  def destination_empty?
    @to_square.occupant == "empty"
  end

  def node_adjacent?(from, to)
    from.connections.include? to.position
  end

  def valid_jump_path?(from, to)
    shared_node(from, to).present? &&
      shared_node(from, to).occupant == enemy_colour &&
       to.occupant == "empty"
  end

  def shared_node(from, to)
    @board.square_by_position((from.connections & to.connections).first)
  end

  def correct_direction?
    case @step.player.colour
    when "red"
      @from_square.position < @to_square.position
    when "white"
      @from_square.position > @to_square.position
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

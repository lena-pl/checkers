class AvailableTurns
  def initialize(player:, board:, piece_position:)
    @player = player
    @board = board
    @piece_position = piece_position
  end

  def more_jump_moves_available?
    more_pieces_can_be_captured?
  end

  def more_simple_moves_available?
    forward_facing_adjacent_piece_positions(@piece_position).any? { |piece_position| @board.square_occupant(piece_position) == "empty" }
  end

  private

  def more_pieces_can_be_captured?
    if adjacent_enemies.present?
      empty_destinations.present?
    else
      false
    end
  end

  def forward_facing_adjacent_piece_positions(position)
    @board.square_connections(position).select do |connection|
      case @player.colour
      when "red"
        connection > @piece_position
      when "white"
        connection < @piece_position
      end
    end
  end

  def adjacent_enemies
    forward_facing_adjacent_piece_positions(@piece_position).select { |position| @board.square_occupant(position) == enemy_colour }
  end

  def enemies_with_directions
    positions = forward_facing_adjacent_piece_positions(@piece_position).sort

    adjacent_enemies.map do |enemy|
      enemy == positions.first ? [enemy, "left"] : [enemy, "right"]
    end
  end

  def empty_destinations
    potential_destinations = enemies_with_directions.map do |enemy_direction_pair|
      enemy = enemy_direction_pair[0]
      direction = enemy_direction_pair[1]
      positions = forward_facing_adjacent_piece_positions(enemy)

      in_horizontal_direction(direction, positions)
    end

    potential_destinations.reject! { |destination| destination == nil }

    potential_destinations.select { |position| @board.square_occupant(position) == "empty" }
  end

  def in_horizontal_direction(direction, positions)
    positions.sort

    direction == "right" ? positions.last : positions.first
  end

  def enemy_colour
    @player.colour == "red" ? "white" : "red"
  end
end

class ConstructBoard
  ALL_POSITIONS_ON_32_SQUARE_BOARD = (1..32).to_a

  #from 2nd row down
  SQUARE_POSITIONS_WITH_TOP_SIMPLE_CONNECTIONS_32_SQUARE_BOARD = (5..32).to_a
  #up to 2nd row up
  SQUARE_POSITIONS_WITH_BOTTOM_SIMPLE_CONNECTIONS_32_SQUARE_BOARD = (1..28).to_a

  #from 3rd row down
  SQUARE_POSITIONS_WITH_TOP_JUMP_CONNECTIONS_32_SQUARE_BOARD = (12..32).to_a
  #up to 3rd row up
  SQUARE_POSITIONS_WITH_BOTTOM_JUMP_CONNECTIONS_32_SQUARE_BOARD = (1..24).to_a

  SQUARES_PER_ROW_32_SQUARE_BOARD = 4

  Square = Struct.new(:position, :occupant, :simple_connections, :jump_connections)
  Piece = Struct.new(:rank, :colour)

  def initialize(positions_and_occupants)
    @positions_and_occupants = positions_and_occupants
  end

  def call
    squares_with_all_connections.map do |position, occupant_colour, simple_connections, jump_connections|
      Square.new(position, occupant_colour != "empty" ? Piece.new("man", occupant_colour) : nil, simple_connections.sort, jump_connections.sort)
    end
  end

  private

  def squares_with_all_connections
    layout = ALL_POSITIONS_ON_32_SQUARE_BOARD.in_groups_of(SQUARES_PER_ROW_32_SQUARE_BOARD)

    top_to_bottom_connections = SQUARE_POSITIONS_WITH_BOTTOM_JUMP_CONNECTIONS_32_SQUARE_BOARD.in_groups_of(SQUARES_PER_ROW_32_SQUARE_BOARD).each_with_index.map {|row, row_index| jump_connections_for_row(layout, row_index) }

    bottom_to_top_connections = SQUARE_POSITIONS_WITH_TOP_JUMP_CONNECTIONS_32_SQUARE_BOARD.reverse.in_groups_of(SQUARES_PER_ROW_32_SQUARE_BOARD).each_with_index.map {|row, row_index| jump_connections_for_row(layout.reverse, row_index) }.reverse

    row_index = 0

    jump_connections = top_to_bottom_connections.each_with_index.map do |(one, two, three, four), index|
      if index > 1
        one += bottom_to_top_connections[row_index][0]
        two += bottom_to_top_connections[row_index][1]
        three += bottom_to_top_connections[row_index][2]
        four += bottom_to_top_connections[row_index][3]

        row_index += 1
      end

      [one, two, three, four]
    end.flatten(1)

    jump_connections += bottom_to_top_connections[4]
    jump_connections += bottom_to_top_connections[5]

    squares_with_simple_connections.each_with_index.map do |square, index|
      !jump_connections[index].nil? ? (square.push jump_connections[index]) : (square.push [])
    end
  end

  def jump_connections_for_row(layout, row_index)
    [[layout[row_index + 2][1]], [layout[row_index + 2][0], layout[row_index + 2][2]], [layout[row_index + 2][1], layout[row_index + 2][3]], [layout[row_index + 2][2]]]
  end

  def squares_with_simple_connections
    top_half_connected = @positions_and_occupants.zip(top_to_bottom_simple_connections)
    flat_top_half_connected = top_half_connected.map {|(position, occupant_colour), connection| [position, occupant_colour, connection]}

    bottom_half_connected = flat_top_half_connected.reverse.zip(bottom_to_top_simple_connections)
    flat_bottom_half_connected = bottom_half_connected.map {|(position, occupant_colour, top_to_bottom_connection), bottom_to_top_connection| [position, occupant_colour, top_to_bottom_connection, bottom_to_top_connection]}

    with_all_connections = flat_bottom_half_connected.map {|square| square.flatten.compact}.reverse

    with_all_connections.map { |square| square[0..1].append(square[2..-1]) }
  end

  def top_to_bottom_simple_connections
    rows = SQUARE_POSITIONS_WITH_TOP_SIMPLE_CONNECTIONS_32_SQUARE_BOARD.in_groups_of(SQUARES_PER_ROW_32_SQUARE_BOARD)
    row_count = 1

    rows.map do |square_one, square_two, square_three, square_four|
      if row_count % 2 != 0
        row_count += 1
        [[square_one, square_two], [square_two, square_three], [square_three, square_four], [square_four]]
      else
        row_count += 1
        [[square_one], [square_one, square_two], [square_two, square_three], [square_three, square_four]]
      end
    end.flatten(1)
  end

  def bottom_to_top_simple_connections
    rows = SQUARE_POSITIONS_WITH_BOTTOM_SIMPLE_CONNECTIONS_32_SQUARE_BOARD.reverse.in_groups_of(SQUARES_PER_ROW_32_SQUARE_BOARD)
    row_count = 1

    rows.map do |square_one, square_two, square_three, square_four|
      if row_count % 2 != 0
        row_count += 1
        [[square_one, square_two], [square_two, square_three], [square_three, square_four], [square_four]]
      else
        row_count += 1
        [[square_one], [square_one, square_two], [square_two, square_three], [square_three, square_four]]
      end
    end.flatten(1)
  end
end

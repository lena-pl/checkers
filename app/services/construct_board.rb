class ConstructBoard
  SQUARE_POSITIONS_WITH_TOP_CONNECTIONS_32_SQUARE_BOARD = (5..32).to_a
  SQUARE_POSITIONS_WITH_BOTTOM_CONNECTIONS_32_SQUARE_BOARD = (1..28).to_a
  AVAILABLE_SQUARES_PER_ROW_32_SQUARE_BOARD = 4

  Square = Struct.new(:position, :occupant, :connections)

  def initialize(squares)
    @squares = squares
  end

  def call
    squares_with_connections.map do |position, occupant, connections|
      Square.new(position, occupant, connections.sort)
    end
  end

  private

  def squares_with_connections
    top_half_connected = @squares.zip(top_to_bottom_connections)
    flat_top_half_connected = top_half_connected.map {|(position, occupant), connection| [position, occupant, connection]}

    bottom_half_connected = flat_top_half_connected.reverse.zip(bottom_to_top_connections)
    flat_bottom_half_connected = bottom_half_connected.map {|(position, occupant, top_to_bottom_connection), bottom_to_top_connection| [position, occupant, top_to_bottom_connection, bottom_to_top_connection]}

    with_all_connections = flat_bottom_half_connected.map {|square| square.flatten.compact}.reverse

    with_all_connections.map { |square| square[0..1].append(square[2..-1]) }
  end

  def top_to_bottom_connections
    rows = SQUARE_POSITIONS_WITH_TOP_CONNECTIONS_32_SQUARE_BOARD.in_groups_of(AVAILABLE_SQUARES_PER_ROW_32_SQUARE_BOARD)
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

  def bottom_to_top_connections
    rows = SQUARE_POSITIONS_WITH_BOTTOM_CONNECTIONS_32_SQUARE_BOARD.reverse.in_groups_of(AVAILABLE_SQUARES_PER_ROW_32_SQUARE_BOARD)
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

class Board
  attr_reader :layout

  def initialize(squares)
    @squares = squares
    @layout = original_layout
  end

  def square_occupant(position)
    square_by_position(position).occupant
  end

  def move_piece(from_position, to_position)
    from = square_by_position(from_position)
    to = square_by_position(to_position)

    @layout = original_layout.map do |square|
      if square.position == to_position
        square.occupant = from.occupant
      elsif square.position == from_position
        square.occupant = "empty"
      end

      square
    end
  end

  private

  Square = Struct.new(:position, :occupant, :connections)

  def original_layout
    squares_with_connections.map do |position, occupant, connections|
      Square.new(position, occupant, connections.sort)
    end
  end

  def square_by_position(pos)
    @layout.find { |square| square.position == pos }
  end

  def squares_with_connections
    top_half_connected = @squares.zip(top_to_bottom_connections)
    flat_top_half_connected = top_half_connected.map {|pos_occ, connection| [pos_occ[0],pos_occ[1], connection]}

    bottom_half_connected = flat_top_half_connected.reverse.zip(bottom_to_top_connections)
    flat_bottom_half_connected = bottom_half_connected.map {|pos_occ_red_con, white_con| [pos_occ_red_con[0], pos_occ_red_con[1], pos_occ_red_con[2], white_con]}

    with_all_connections = flat_bottom_half_connected.map {|square| square.flatten.reject(&:blank?)}.reverse

    with_all_connections.map { |square| square[0..1].append(square[2..-1]) }
  end

  def top_to_bottom_connections
    rows = (5..32).to_a.in_groups_of(4)
    row_count = 1

    rows.map do |row|
      if row_count % 2 != 0
        row_count += 1
        [[row[0], row[1]], [row[1], row[2]], [row[2], row[3]], [row[3]]]
      else
        row_count +=1
        [[row[0]], [row[0], row[1]], [row[1], row[2]], [row[2], row[3]]]
      end
    end.flatten(1)
  end

  def bottom_to_top_connections
    rows = (1..28).to_a.reverse.in_groups_of(4)
    row_count = 1

    rows.map do |row|
      if row_count % 2 != 0
        row_count += 1
        [[row[0], row[1]], [row[1], row[2]], [row[2], row[3]], [row[3]]]
      else
        row_count +=1
        [[row[0]], [row[0], row[1]], [row[1], row[2]], [row[2], row[3]]]
      end
    end.flatten(1)
  end
end

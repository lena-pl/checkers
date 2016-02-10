class Board
  def initialize(squares)
    @squares = squares
  end

  Square = Struct.new(:position, :coordinates, :occupant)

  def cartesian_layout
    y_coord = 8

    rows_with_duds.map do |row|
      x_coord = 1
      new_layout = row.map do |square|
        square.coordinates = [x_coord, y_coord]
        x_coord += 1
        square
      end
      y_coord -= 1
      new_layout
    end.flatten
  end

  def square_by_coordinates(x_coord, y_coord)
    cartesian_layout.find { |square| square.coordinates == [x_coord, y_coord] }
  end

  def square_by_position(pos)
    cartesian_layout.find { |square| square.position == pos }
  end

  private

  def rows_with_duds
    hashed_layout.in_groups_of(8).map do |square_1, square_2, square_3, square_4, square_5, square_6, square_7, square_8|
      [square_1, square_2, square_3, square_4, square_5, square_6, square_7, square_8]
    end
  end

  def hashed_layout
    multidimensional_layout_with_duds.flatten.in_groups_of(2).map do |position, occupant|
      Square.new(position, "unknown", occupant)
    end
  end

  def multidimensional_layout_with_duds
    row_count = 0

    @squares.in_groups_of(4).map do |square_1, square_2, square_3, square_4|
      row = [square_1, square_2, square_3, square_4]
      dud_array = [nil, nil, nil, nil]
      duds = dud_array.map { |pos| [pos, "dud"]  }

      if row_count == 0 || row_count % 2 == 0
        row_count += 1
        duds.zip(row)
      else
        row_count +=1
        row.zip(duds)
      end
    end
  end
end

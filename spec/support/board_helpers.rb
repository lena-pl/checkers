module BoardHelpers
  def square(position, occupant, simple_connections, jump_connections)
    ConstructBoard::Square.new(position, occupant != "empty" ? ConstructBoard::Piece.new("man", occupant) : nil, simple_connections, jump_connections)
  end

  def board_layout_as_string(board_layout)
    pieces = board_layout.map(&:occupant)

    pieces_as_string = pieces.map { |piece| present_piece(piece) }.join

    pieces_as_string.chars.in_groups_of(4).each_with_index.map do |row, index|
      if index % 2 != 0
        row = row.zip([".", ".", ".", "."])
      else
        row = [".", ".", ".", "."].zip(row)
      end

      row.push "\n"
    end.join
  end

  private

  def present_piece(piece)
    if piece.nil?
      "_"
    else
      (piece.colour == "red" ? "r" : "w").tap do |str|
        str.upcase! if piece.rank == "king"
      end
    end
  end
end

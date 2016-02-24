module BoardHelpers
  def square(position:, occupant:, connections:)
    ConstructBoard::Square.new(position, occupant != "empty" ? ConstructBoard::Piece.new("man", occupant) : nil, connections)
  end
end

module BoardHelpers
  def square(position:, occupant:, connections:)
    ConstructStartingBoard::Square.new(position, occupant != "empty" ? ConstructStartingBoard::Piece.new("man", occupant) : nil, connections)
  end
end

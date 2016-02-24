module BoardHelpers
  def square(position:, occupant:, connections:)
    ConstructBoard::Square.new(position, occupant, connections)
  end
end

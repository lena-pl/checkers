class Board
  def initialize(squares)
    @squares = squares.flatten
  end

  Square = Struct.new(:position, :player_colour)

  def occupied
    @squares.in_groups_of(2).map do |position, player_colour|
      Square.new(position, player_colour)
    end
  end

  def active_pieces_count(player)
    occupied.count {|square| square.player_colour == player.colour}
  end
end

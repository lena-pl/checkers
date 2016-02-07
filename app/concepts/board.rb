class Board
  def initialize(occupied_positions)
    @occupied_positions = occupied_positions
  end

  def occupied
    Hash[*@occupied_positions.flatten]
  end

  def active_red_pieces_count
    @occupied_positions.count{|pos| pos[1] == "red"}
  end

  def active_white_pieces_count
    @occupied_positions.count{|pos| pos[1] == "white"}
  end
end

class Board
  attr_reader :squares, :layout

  def initialize(squares)
    @squares = squares
    @layout = original_layout
  end

  def square_occupant(position)
    square_by_position(position).occupant
  end

  def square_connections(position)
    square_by_position(position).connections
  end

  def shared_piece_position(from, to)
    (square_connections(from) & square_connections(to)).first
  end

  def player_pieces(player)
    layout.select { |square| square_occupant(square.position).colour == player.colour if !square_occupant(square.position).nil? }
  end

  def capture_piece(position)
    layout.map do |square|
      if square.position == position
        square.occupant = nil
      end

      square
    end
  end

  def move_piece(from_position, to_position)
    from_square = square_by_position(from_position)
    piece = from_square.occupant

    layout.map do |square|
      if square.position == to_position
        square.occupant = piece
      elsif square.position == from_position
        square.occupant = nil
      end

      square
    end
  end

  private

  def original_layout
    ConstructStartingBoard.new(squares).call
  end

  def square_by_position(pos)
    layout.find { |square| square.position == pos }
  end
end

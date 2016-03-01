class Board
  attr_reader :positions_and_occupants, :layout

  ORIGINAL_RED_PIECE_POSITIONS_32_SQUARE_BOARD = (1..12).to_a
  ORIGINAL_EMPTY_SQUARE_POSITIONS_32_SQUARE_BOARD = (13..20).to_a
  ORIGINAL_WHITE_PIECE_POSITIONS_32_SQUARE_BOARD = (21..32).to_a

  RED_PLAYER_KINGS_ROW_32_SQUARE_BOARD = [29, 30, 31, 32]
  WHITE_PLAYER_KINGS_ROW_32_SQUARE_BOARD = [1, 2, 3, 4]

  def initialize(positions_and_occupants = default_positions_and_occupants)
    @positions_and_occupants = positions_and_occupants
    @layout = original_layout
  end

  def square_occupant(position)
    square_by_position(position).occupant
  end

  def square_simple_connections(position)
    square_by_position(position).simple_connections
  end

  def square_jump_connections(position)
    square_by_position(position).jump_connections
  end

  def shared_piece_position(from, to)
    (square_simple_connections(from) & square_simple_connections(to)).first
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

  def crown_piece(piece_position)
    piece = square_by_position(piece_position)

    piece.occupant.rank = "king"

    piece
  end

  def kings_row(player)
    if player.red?
      RED_PLAYER_KINGS_ROW_32_SQUARE_BOARD
    elsif player.white?
      WHITE_PLAYER_KINGS_ROW_32_SQUARE_BOARD
    end
  end

  private

  def original_layout
    ConstructBoard.new(positions_and_occupants).call
  end

  def square_by_position(pos)
    layout.find { |square| square.position == pos }
  end

  def default_positions_and_occupants
    red_occupied = ORIGINAL_RED_PIECE_POSITIONS_32_SQUARE_BOARD.map { |number| [number, "red"]  }
    empty = ORIGINAL_EMPTY_SQUARE_POSITIONS_32_SQUARE_BOARD.map { |number| [number, "empty"]  }
    white_occupied = ORIGINAL_WHITE_PIECE_POSITIONS_32_SQUARE_BOARD.map { |number| [number, "white"]  }

    red_occupied + empty + white_occupied
  end
end

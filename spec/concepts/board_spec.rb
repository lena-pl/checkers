require 'rails_helper'
require_relative '../support/board_helpers'

RSpec.describe Board do
  include BoardHelpers

  let(:squares) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "red"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "empty"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "white"], [25, "white"], [26, "white"], [27, "white"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "white"]] }
  subject { Board.new(squares) }
  let(:game) { Game.create! }
  let(:player_one) { game.players.create!(colour: :red) }
  let(:player_two) { game.players.create!(colour: :white) }

  describe "#layout" do
    it "returns an array of square structs with correct positions, connections and occupants" do
      expect(board_layout_as_string(subject.layout)).to eql <<-BOARD.gsub(/^ {8}/, '')
        .r.r.r.r
        r.r.r.r.
        .r.r.r.r
        _._._._.
        ._._._._
        w.w.w.w.
        .w.w.w.w
        w.w.w.w.
      BOARD

      expect(subject.layout).to eql [
        square(1, "red", [5, 6]),
        square(2, "red", [6, 7]),
        square(3, "red", [7, 8]),
        square(4, "red", [8]),
        square(5, "red", [1, 9]),
        square(6, "red", [1, 2, 9, 10]),
        square(7, "red", [2, 3, 10, 11]),
        square(8, "red", [3, 4, 11, 12]),
        square(9, "red", [5, 6, 13, 14]),
        square(10, "red", [6, 7, 14, 15]),
        square(11, "red", [7, 8, 15, 16]),
        square(12, "red", [8, 16]),
        square(13, "empty", [9, 17]),
        square(14, "empty", [9, 10, 17, 18]),
        square(15, "empty", [10, 11, 18, 19]),
        square(16, "empty", [11, 12, 19, 20]),
        square(17, "empty", [13, 14, 21, 22]),
        square(18, "empty", [14, 15, 22, 23]),
        square(19, "empty", [15, 16, 23, 24]),
        square(20, "empty", [16, 24]),
        square(21, "white", [17, 25]),
        square(22, "white", [17, 18, 25, 26]),
        square(23, "white", [18, 19, 26, 27]),
        square(24, "white", [19, 20, 27, 28]),
        square(25, "white", [21, 22, 29, 30]),
        square(26, "white", [22, 23, 30, 31]),
        square(27, "white", [23, 24, 31, 32]),
        square(28, "white", [24, 32]),
        square(29, "white", [25]),
        square(30, "white", [25, 26]),
        square(31, "white", [26, 27]),
        square(32, "white", [27, 28])
      ]
    end
  end

  describe "#square_occupant" do
    it "returns the correct square occupant, given a checker board position" do
      square_four = square(squares[3][0], squares[3][1], [8])

      expect(subject.square_occupant(4)).to eq square_four.occupant
    end
  end

  describe "#square_connections" do
    it "returns the correct square connections, given a checker board position" do
      square_four = square(squares[3][0], squares[3][1], [8])

      expect(subject.square_connections(4)).to eq square_four.connections
    end
  end

  describe "#player_pieces" do
    it "returns all the pieces currently on the board for a given player" do
      expect(subject.player_pieces(player_one)).to eq [
        square(1, "red", [5, 6]),
        square(2, "red", [6, 7]),
        square(3, "red", [7, 8]),
        square(4, "red", [8]),
        square(5, "red", [1, 9]),
        square(6, "red", [1, 2, 9, 10]),
        square(7, "red", [2, 3, 10, 11]),
        square(8, "red", [3, 4, 11, 12]),
        square(9, "red", [5, 6, 13, 14]),
        square(10, "red", [6, 7, 14, 15]),
        square(11, "red", [7, 8, 15, 16]),
        square(12, "red", [8, 16])
      ]
    end
  end

  describe "#capture_piece" do
    it "captures a piece in a given position" do
      square_ten = square(squares[9][0], squares[9][1], [6, 7, 14, 15])

      subject.capture_piece(10)

      expect(subject.square_occupant(10)).to eq nil

      expect(board_layout_as_string(subject.layout)).to eql <<-BOARD.gsub(/^ {8}/, '')
        .r.r.r.r
        r.r.r.r.
        .r._.r.r
        _._._._.
        ._._._._
        w.w.w.w.
        .w.w.w.w
        w.w.w.w.
      BOARD
    end
  end

  describe "#move_piece" do
    it "moves a piece from a given position to another given position, updating the board layout" do
      square_ten = square(squares[9][0], squares[9][1], [6, 7, 14, 15])

      subject.move_piece(10, 15)

      expect(subject.square_occupant(10)).to eq nil
      expect(subject.square_occupant(15)).to eq square_ten.occupant

      expect(board_layout_as_string(subject.layout)).to eql <<-BOARD.gsub(/^ {8}/, '')
        .r.r.r.r
        r.r.r.r.
        .r._.r.r
        _._.r._.
        ._._._._
        w.w.w.w.
        .w.w.w.w
        w.w.w.w.
      BOARD
    end
  end

  describe "#crown_piece" do
    it "changes the rank of a piece from man to king" do
      expect(subject.square_occupant(10).rank).to eq "man"

      subject.crown_piece(10)

      expect(subject.square_occupant(10).rank).to eq "king"
    end
  end

  describe "#kings_row" do
    it "returns the correct king's row positions for a red player" do
      expect(subject.kings_row(player_one)).to eq Board::RED_PLAYER_KINGS_ROW_32_SQUARE_BOARD
    end

    it "returns the correct king's row positions for a white player" do
      expect(subject.kings_row(player_two)).to eq Board::WHITE_PLAYER_KINGS_ROW_32_SQUARE_BOARD
    end
  end
end

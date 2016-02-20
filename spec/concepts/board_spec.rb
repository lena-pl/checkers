require 'rails_helper'

RSpec.describe Board do
  let(:squares) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "red"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "empty"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "white"], [25, "white"], [26, "white"], [27, "white"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "white"]] }
  subject { Board.new(squares) }
  let(:game) { Game.create! }
  let(:player_one) { game.players.create!(colour: :red) }
  let(:player_two) { game.players.create!(colour: :white) }

  describe "#layout" do
    it "returns an array of square structs with correct positions, coordinates and occupants" do
      expect(subject.layout).to eql [Board::Square.new(1, "red", [5, 6]), Board::Square.new(2, "red", [6, 7]), Board::Square.new(3, "red", [7, 8]), Board::Square.new(4, "red", [8]), Board::Square.new(5, "red", [1, 9]), Board::Square.new(6, "red", [1, 2, 9, 10]), Board::Square.new(7, "red", [2, 3, 10, 11]), Board::Square.new(8, "red", [3, 4, 11, 12]), Board::Square.new(9, "red", [5, 6, 13, 14]), Board::Square.new(10, "red", [6, 7, 14, 15]), Board::Square.new(11, "red", [7, 8, 15, 16]), Board::Square.new(12, "red", [8, 16]), Board::Square.new(13, "empty", [9, 17]), Board::Square.new(14, "empty", [9, 10, 17, 18]), Board::Square.new(15, "empty", [10, 11, 18, 19]), Board::Square.new(16, "empty", [11, 12, 19, 20]), Board::Square.new(17, "empty", [13, 14, 21, 22]), Board::Square.new(18, "empty", [14, 15, 22, 23]), Board::Square.new(19, "empty", [15, 16, 23, 24]), Board::Square.new(20, "empty", [16, 24]), Board::Square.new(21, "white", [17, 25]), Board::Square.new(22, "white", [17, 18, 25, 26]), Board::Square.new(23, "white", [18, 19, 26, 27]), Board::Square.new(24, "white", [19, 20, 27, 28]), Board::Square.new(25, "white", [21, 22, 29, 30]), Board::Square.new(26, "white", [22, 23, 30, 31]), Board::Square.new(27, "white", [23, 24, 31, 32]), Board::Square.new(28, "white", [24, 32]), Board::Square.new(29, "white", [25]), Board::Square.new(30, "white", [25, 26]), Board::Square.new(31, "white", [26, 27]), Board::Square.new(32, "white", [27, 28])]
    end
  end

  describe "#square_occupant" do
    it "returns the correct square occupant, given a checker board position" do
      square_four = Board::Square.new(squares[3][0], squares[3][1], [8])

      expect(subject.square_occupant(4)).to eq square_four.occupant
    end
  end

  describe "#move_piece" do
    it "moves a piece from a given position to another given position, updating the board layout" do
      subject.move_piece(10, 15)

      expect(subject.layout).to eql [Board::Square.new(1, "red", [5, 6]), Board::Square.new(2, "red", [6, 7]), Board::Square.new(3, "red", [7, 8]), Board::Square.new(4, "red", [8]), Board::Square.new(5, "red", [1, 9]), Board::Square.new(6, "red", [1, 2, 9, 10]), Board::Square.new(7, "red", [2, 3, 10, 11]), Board::Square.new(8, "red", [3, 4, 11, 12]), Board::Square.new(9, "red", [5, 6, 13, 14]), Board::Square.new(10, "empty", [6, 7, 14, 15]), Board::Square.new(11, "red", [7, 8, 15, 16]), Board::Square.new(12, "red", [8, 16]), Board::Square.new(13, "empty", [9, 17]), Board::Square.new(14, "empty", [9, 10, 17, 18]), Board::Square.new(15, "red", [10, 11, 18, 19]), Board::Square.new(16, "empty", [11, 12, 19, 20]), Board::Square.new(17, "empty", [13, 14, 21, 22]), Board::Square.new(18, "empty", [14, 15, 22, 23]), Board::Square.new(19, "empty", [15, 16, 23, 24]), Board::Square.new(20, "empty", [16, 24]), Board::Square.new(21, "white", [17, 25]), Board::Square.new(22, "white", [17, 18, 25, 26]), Board::Square.new(23, "white", [18, 19, 26, 27]), Board::Square.new(24, "white", [19, 20, 27, 28]), Board::Square.new(25, "white", [21, 22, 29, 30]), Board::Square.new(26, "white", [22, 23, 30, 31]), Board::Square.new(27, "white", [23, 24, 31, 32]), Board::Square.new(28, "white", [24, 32]), Board::Square.new(29, "white", [25]), Board::Square.new(30, "white", [25, 26]), Board::Square.new(31, "white", [26, 27]), Board::Square.new(32, "white", [27, 28])] 
    end
  end
end

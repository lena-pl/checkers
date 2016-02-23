require 'rails_helper'

RSpec.describe ConstructBoard do
  let(:squares) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "red"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "empty"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "white"], [25, "white"], [26, "white"], [27, "white"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "white"]] }
  subject { Board.new(squares) }
  let(:game) { Game.create! }
  let(:player_one) { game.players.create!(colour: :red) }
  let(:player_two) { game.players.create!(colour: :white) }

  describe "#call" do
    it "returns an array of square structs with correct positions, connections and occupants" do
      expect(subject.layout).to eql [ConstructBoard::Square.new(1, "red", [5, 6]), ConstructBoard::Square.new(2, "red", [6, 7]), ConstructBoard::Square.new(3, "red", [7, 8]), ConstructBoard::Square.new(4, "red", [8]), ConstructBoard::Square.new(5, "red", [1, 9]), ConstructBoard::Square.new(6, "red", [1, 2, 9, 10]), ConstructBoard::Square.new(7, "red", [2, 3, 10, 11]), ConstructBoard::Square.new(8, "red", [3, 4, 11, 12]), ConstructBoard::Square.new(9, "red", [5, 6, 13, 14]), ConstructBoard::Square.new(10, "red", [6, 7, 14, 15]), ConstructBoard::Square.new(11, "red", [7, 8, 15, 16]), ConstructBoard::Square.new(12, "red", [8, 16]), ConstructBoard::Square.new(13, "empty", [9, 17]), ConstructBoard::Square.new(14, "empty", [9, 10, 17, 18]), ConstructBoard::Square.new(15, "empty", [10, 11, 18, 19]), ConstructBoard::Square.new(16, "empty", [11, 12, 19, 20]), ConstructBoard::Square.new(17, "empty", [13, 14, 21, 22]), ConstructBoard::Square.new(18, "empty", [14, 15, 22, 23]), ConstructBoard::Square.new(19, "empty", [15, 16, 23, 24]), ConstructBoard::Square.new(20, "empty", [16, 24]), ConstructBoard::Square.new(21, "white", [17, 25]), ConstructBoard::Square.new(22, "white", [17, 18, 25, 26]), ConstructBoard::Square.new(23, "white", [18, 19, 26, 27]), ConstructBoard::Square.new(24, "white", [19, 20, 27, 28]), ConstructBoard::Square.new(25, "white", [21, 22, 29, 30]), ConstructBoard::Square.new(26, "white", [22, 23, 30, 31]), ConstructBoard::Square.new(27, "white", [23, 24, 31, 32]), ConstructBoard::Square.new(28, "white", [24, 32]), ConstructBoard::Square.new(29, "white", [25]), ConstructBoard::Square.new(30, "white", [25, 26]), ConstructBoard::Square.new(31, "white", [26, 27]), ConstructBoard::Square.new(32, "white", [27, 28])]
    end
  end
end

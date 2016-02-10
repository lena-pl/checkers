require 'rails_helper'

RSpec.describe Board do
  let(:squares) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"]] }
  subject { Board.new(squares) }
  let(:game) { Game.create! }
  let(:player_one) { game.players.create!(colour: :red) }
  let(:player_two) { game.players.create!(colour: :white) }

  describe "#cartesian_layout" do
    it "returns an array of square structs with correct positions, coordinates and occupants" do
      dud_one = Board::Square.new(nil, [1,8], "dud")
      square_one = Board::Square.new(squares[0][0], [2,8], squares[0][1])
      dud_two = Board::Square.new(nil, [3,8], "dud")
      square_two = Board::Square.new(squares[1][0], [4,8], squares[1][1])
      dud_three = Board::Square.new(nil, [5,8], "dud")
      square_three = Board::Square.new(squares[2][0], [6,8], squares[2][1])
      dud_four = Board::Square.new(nil, [7,8], "dud")
      square_four = Board::Square.new(squares[3][0], [8,8], squares[3][1])

      square_five = Board::Square.new(squares[4][0], [1,7], squares[4][1])
      dud_five = Board::Square.new(nil, [2,7], "dud")
      square_six = Board::Square.new(squares[5][0], [3,7], squares[5][1])
      dud_six = Board::Square.new(nil, [4,7], "dud")
      square_seven = Board::Square.new(squares[6][0], [5,7], squares[6][1])
      dud_seven = Board::Square.new(nil, [6,7], "dud")
      square_eight = Board::Square.new(squares[7][0], [7,7], squares[7][1])
      dud_eight = Board::Square.new(nil, [8,7], "dud")

      expect(subject.cartesian_layout).to eql [dud_one, square_one, dud_two, square_two, dud_three, square_three, dud_four, square_four, square_five, dud_five, square_six, dud_six, square_seven, dud_seven, square_eight, dud_eight]
    end
  end

  describe "#square_by_coordinates" do
    it "returns the correct square, given a set of cartesian coordinates" do
      square_four = Board::Square.new(squares[3][0], [8,8],  squares[3][1])

      expect(subject.square_by_coordinates(8,8)).to eq square_four
    end
  end

  describe "#square_by_position" do
    it "returns the correct square, given a checker board position" do
      square_four = Board::Square.new(squares[3][0], [8,8],  squares[3][1])

      expect(subject.square_by_position(4)).to eq square_four
    end
  end
end

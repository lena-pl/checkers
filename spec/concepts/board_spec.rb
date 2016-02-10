require 'rails_helper'

RSpec.describe Board do
  let(:squares) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"]] }
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

      expect(subject.cartesian_layout).to eql [dud_one, square_one, dud_two, square_two, dud_three, square_three, dud_four, square_four]
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

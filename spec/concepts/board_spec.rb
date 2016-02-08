require 'rails_helper'

RSpec.describe Board do
  let(:squares) { [[1, "red"], [2, "red"], [32, "white"]] }
  subject { Board.new(squares) }
  let(:game) { Game.create! }
  let(:player_one) { game.players.create!(colour: :red) }
  let(:player_two) { game.players.create!(colour: :white) }

  describe "#occupied" do
    it "returns an array of occupied square structs" do
      square_one = Board::Square.new(squares[0][0], squares[0][1])
      square_two = Board::Square.new(squares[1][0], squares[1][1])
      square_three = Board::Square.new(squares[2][0], squares[2][1])

      expect(subject.occupied).to eql [square_one, square_two, square_three]
    end
  end

  describe "#active_pieces_count" do
    it "returns the count of red pieces on the board" do
      expect(subject.active_pieces_count(player_one)).to eql 2
    end
  end
end

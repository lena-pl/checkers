require 'rails_helper'

RSpec.describe Board do
  let(:squares) { [[1, "red"], [32, "white"]] }
  subject { Board.new(squares) }

  describe "#occupied" do
    it "returns an array of occupied square structs" do
      square_one = Board::Square.new(squares[0][0], squares[0][1])
      square_two = Board::Square.new(squares[1][0], squares[1][1])

      expect(subject.occupied).to eql [square_one, square_two]
    end
  end

  describe "#active_red_pieces_count" do
    it "returns the count of red pieces on the board" do
      expect(subject.active_red_pieces_count).to eql 1
    end
  end

  describe "#active_red_pieces_count" do
    it "returns the count of white pieces on the board" do
      expect(subject.active_white_pieces_count).to eql 1
    end
  end
end

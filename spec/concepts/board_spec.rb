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
end

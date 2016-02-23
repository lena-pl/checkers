require 'rails_helper'

RSpec.describe AvailableTurns do
  let!(:game) { Game.create! }
  let!(:player_one) { game.players.create!(colour: :red) }
  let!(:player_two) { game.players.create!(colour: :white) }

  let(:squares) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "red"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "empty"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "white"], [25, "white"], [26, "white"], [27, "white"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "white"]] }
  let(:board) { Board.new(squares) }

  context "a piece only has simple moves available" do
    describe "#more_simple_moves_available?" do
      it "returns true" do
        expect(AvailableTurns.new(player: player_one, board: board, piece_position: 11).more_simple_moves_available?).to eq true
      end
    end

    describe "#more_jump_moves_available?" do
      it "returns false" do
        expect(AvailableTurns.new(player: player_one, board: board, piece_position: 11).more_jump_moves_available?).to eq false
      end
    end
  end

  context "a piece only has a jump move available" do
    let(:squares) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "empty"], [13, "empty"], [14, "empty"], [15, "white"], [16, "red"], [17, "empty"], [18, "empty"], [19, "empty"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "empty"], [25, "white"], [26, "white"], [27, "white"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "white"]] }

    describe "#more_simple_moves_available?" do
      it "returns false" do
        expect(AvailableTurns.new(player: player_one, board: board, piece_position: 11).more_simple_moves_available?).to eq false
      end
    end

    describe "#more_jump_moves_available?" do
      it "returns true" do
        expect(AvailableTurns.new(player: player_one, board: board, piece_position: 11).more_jump_moves_available?).to eq true
      end
    end
  end

  context "a piece has a jump move and a simple move available" do
    let(:squares) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "red"], [13, "empty"], [14, "empty"], [15, "white"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "empty"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "empty"], [25, "white"], [26, "white"], [27, "white"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "white"]] }

    describe "#more_simple_moves_available?" do
      it "returns true" do
        expect(AvailableTurns.new(player: player_one, board: board, piece_position: 11).more_simple_moves_available?).to eq true
      end
    end

    describe "#more_jump_moves_available?" do
      it "returns true" do
        expect(AvailableTurns.new(player: player_one, board: board, piece_position: 11).more_jump_moves_available?).to eq true
      end
    end
  end
end

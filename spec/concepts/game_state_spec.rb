require 'rails_helper'

RSpec.describe GameState do
  let!(:game) { Game.create! }
  let!(:player_one) { game.players.create!(colour: :red) }
  let!(:player_two) { game.players.create!(colour: :white) }

  let(:squares) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "red"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "empty"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "white"], [25, "white"], [26, "white"], [27, "white"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "white"]] }
  let(:board) { Board.new(squares) }

  let(:game_state) { GameState.new(game, board, player_one) }

  context "when the game is in progress" do
    describe "#over?" do
      it "returns false" do
        expect(game_state.over?).to eq false
      end
    end

    describe "winner" do
      it "returns nil" do
        expect(game_state.winner).to eq nil
      end
    end

    describe "loser" do
      it "returns nil" do
        expect(game_state.loser).to eq nil
      end
    end

    describe "#draw?" do
      it "returns false" do
        expect(game_state.draw?).to eq false
      end
    end
  end

  context "when the game is over and red won" do
    let(:squares) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "red"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "empty"], [20, "empty"], [21, "empty"], [22, "empty"], [23, "empty"], [24, "empty"], [25, "empty"], [26, "empty"], [27, "empty"], [28, "empty"], [29, "empty"], [30, "empty"], [31, "empty"], [32, "empty"]] }

    describe "#over?" do
      it "returns true" do
        expect(game_state.over?).to eq true
      end
    end

    describe "winner" do
      it "returns red player" do
        expect(game_state.winner).to eq player_one
      end
    end

    describe "loser" do
      it "returns white player" do
        expect(game_state.loser).to eq player_two
      end
    end

    describe "#draw?" do
      it "returns false" do
        expect(game_state.draw?).to eq false
      end
    end
  end

  context "when the game is over and is a draw" do
    let(:squares) { [[1, "white"], [2, "empty"], [3, "empty"], [4, "empty"], [5, "empty"], [6, "empty"], [7, "empty"], [8, "empty"], [9, "empty"], [10, "empty"], [11, "empty"], [12, "empty"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "empty"], [20, "empty"], [21, "empty"], [22, "empty"], [23, "empty"], [24, "empty"], [25, "empty"], [26, "empty"], [27, "empty"], [28, "empty"], [29, "empty"], [30, "empty"], [31, "empty"], [32, "red"]] }

    describe "#over?" do
      it "returns true" do
        expect(game_state.over?).to eq true
      end
    end

    describe "winner" do
      it "returns nil" do
        expect(game_state.winner).to eq nil
      end
    end

    describe "loser" do
      it "returns nil" do
        expect(game_state.loser).to eq nil
      end
    end

    describe "#draw?" do
      it "returns true" do
        expect(game_state.draw?).to eq true
      end
    end
  end
end

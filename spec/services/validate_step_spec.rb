require 'rails_helper'

RSpec.describe ValidateStep do
  let(:squares) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "red"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "empty"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "white"], [25, "white"], [26, "white"], [27, "white"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "white"]] }
  let(:board) { Board.new(squares) }

  let(:game) { Game.create! }
  let(:player_one) { game.players.create!(colour: :red) }
  let(:player_two) { game.players.create!(colour: :white) }

  describe "#call" do
    context "when the step is a legal simple step" do
      let(:step) { player_one.steps.create!(kind: :simple, from: 12, to: 16) }

      it "returns true" do
        service = ValidateStep.new(board, step)

        expect(service.call).to eq true
        expect(service.errors).to be_empty
      end
    end

    context "when the step is an illegal simple step" do
      let(:step) { player_one.steps.create!(kind: :simple, from: 12, to: 8) }

      it "returns correct errors and false" do
        service = ValidateStep.new(board, step)

        expect(service.call).to eq false
        expect(service.errors).to eq ["You can only move forward!", "That square is occupied!"]
      end
    end

    context "when the step is a legal jump step" do
      let(:squares) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "empty"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "red"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "white"], [25, "white"], [26, "white"], [27, "white"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "white"]] }

      let(:step) { player_two.steps.create!(kind: :jump, from: 24, to: 15) }

      it "returns true" do
        service = ValidateStep.new(board, step)

        expect(service.call).to eq true
        expect(service.errors).to be_empty
      end
    end

    context "when the step is an illegal jump step" do
      let(:step) { player_one.steps.create!(kind: :jump, from: 12, to: 19) }

      it "returns errors and false" do
        service = ValidateStep.new(board, step)

        expect(service.call).to eq false
        expect(service.errors).to eq ["That is not a valid jump path!"]
      end
    end
  end
end

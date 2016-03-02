require 'rails_helper'

RSpec.describe AvailableJumpDestinations do
  let(:positions_and_occupants) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "red"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "empty"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "white"], [25, "white"], [26, "white"], [27, "white"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "white"]] }
  let(:board) { Board.new(positions_and_occupants) }

  let(:game) { Game.create! }
  let(:player_one) { game.players.create!(colour: :red) }
  let(:player_two) { game.players.create!(colour: :white) }

  describe "#call" do
    context "when the piece is a man" do
      context "when the step is a legal jump step" do
        let(:positions_and_occupants) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "empty"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "red"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "white"], [25, "white"], [26, "white"], [27, "white"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "white"]] }

        let(:step) { player_two.steps.create!(kind: :jump, from: 24, to: 15) }

        it "contains the destination as available" do
          service = AvailableJumpDestinations.new(board, player_two, step.from)

          expect(service.call).to include 15
          expect(service.errors).to be_empty
        end
      end

      context "when the step is an illegal jump step" do
        let(:step) { player_one.steps.create!(kind: :jump, from: 12, to: 19) }

        it "does not contain the destination" do
          service = AvailableJumpDestinations.new(board, player_one, step.from)

          expect(service.call).not_to include step.to
        end
      end
    end

    context "when the piece is a king" do
      before do
        player_one.steps.create!(kind: :simple, from: 12, to: 16)
        player_two.steps.create!(kind: :simple, from: 23, to: 18)

        player_one.steps.create!(kind: :simple, from: 16, to: 19)
        player_two.steps.create!(kind: :simple, from: 18, to: 14)

        player_one.steps.create!(kind: :simple, from: 11, to: 15)
        player_two.steps.create!(kind: :simple, from: 27, to: 23)

        player_one.steps.create!(kind: :simple, from: 9, to: 13)
        player_two.steps.create!(kind: :simple, from: 32, to: 27)

        player_one.steps.create!(kind: :jump, from: 10, to: 17)
        player_two.steps.create!(kind: :simple, from: 23, to: 18)

        player_one.steps.create!(kind: :simple, from: 8, to: 12)
        player_two.steps.create!(kind: :simple, from: 18, to: 14)

        player_one.steps.create!(kind: :simple, from: 19, to: 23)
        player_two.steps.create!(kind: :simple, from: 14, to: 9)

        player_one.steps.create!(kind: :jump, from: 23, to: 32)
        player_two.steps.create!(kind: :simple, from: 31, to: 27)
      end

      context "when a crowned piece tries to jump in that colour's wrong direction" do
        let(:board) { BuildGameState.new(game).call.board }

        it "contains the destination as available" do
          service = AvailableJumpDestinations.new(board, player_one, 32)

          expect(service.call).to include 23
          expect(service.errors).to be_empty
        end
      end
    end
  end
end

require 'rails_helper'
require_relative '../support/board_helpers'

RSpec.describe TakeTurn do
  include BoardHelpers

  let!(:game) { Game.create! }
  let!(:player_one) { game.players.create!(colour: :red) }
  let!(:player_two) { game.players.create!(colour: :white) }

  let(:base_game_state) { BuildGameState.new(game).call }

  describe "#call" do
    context "when the service is passed an empty chunk of steps" do
      let(:steps) { [] }

      it "returns the old game state" do
        service = TakeTurn.new(game_state: base_game_state, player: player_one, steps: steps)

        expect(service.call).to eq base_game_state
      end
    end

    context "when the player is allowed to move" do
      context "when only 1 step is taken" do
        let(:steps) { [player_one.steps.create!(kind: :simple, from: 12, to: 16)] }

        it "applies the step and returns the new game state without errors" do
          service = TakeTurn.new(game_state: base_game_state, player: player_one, steps: steps)
          service.call

          expect(service.errors).to be_empty
          expect(service.game_state.current_player).to eq player_two
          expect(service.game_state.board.layout).to eql [
            square(position: 1, occupant: "red", connections: [5, 6]),
            square(position: 2, occupant: "red", connections: [6, 7]),
            square(position: 3, occupant: "red", connections: [7, 8]),
            square(position: 4, occupant: "red", connections: [8]),
            square(position: 5, occupant: "red", connections: [1, 9]),
            square(position: 6, occupant: "red", connections: [1, 2, 9, 10]),
            square(position: 7, occupant: "red", connections: [2, 3, 10, 11]),
            square(position: 8, occupant: "red", connections: [3, 4, 11, 12]),
            square(position: 9, occupant: "red", connections: [5, 6, 13, 14]),
            square(position: 10, occupant: "red", connections: [6, 7, 14, 15]),
            square(position: 11, occupant: "red", connections: [7, 8, 15, 16]),
            square(position: 12, occupant: "empty", connections: [8, 16]),
            square(position: 13, occupant: "empty", connections: [9, 17]),
            square(position: 14, occupant: "empty", connections: [9, 10, 17, 18]),
            square(position: 15, occupant: "empty", connections: [10, 11, 18, 19]),
            square(position: 16, occupant: "red", connections: [11, 12, 19, 20]),
            square(position: 17, occupant: "empty", connections: [13, 14, 21, 22]),
            square(position: 18, occupant: "empty", connections: [14, 15, 22, 23]),
            square(position: 19, occupant: "empty", connections: [15, 16, 23, 24]),
            square(position: 20, occupant: "empty", connections: [16, 24]),
            square(position: 21, occupant: "white", connections: [17, 25]),
            square(position: 22, occupant: "white", connections: [17, 18, 25, 26]),
            square(position: 23, occupant: "white", connections: [18, 19, 26, 27]),
            square(position: 24, occupant: "white", connections: [19, 20, 27, 28]),
            square(position: 25, occupant: "white", connections: [21, 22, 29, 30]),
            square(position: 26, occupant: "white", connections: [22, 23, 30, 31]),
            square(position: 27, occupant: "white", connections: [23, 24, 31, 32]),
            square(position: 28, occupant: "white", connections: [24, 32]),
            square(position: 29, occupant: "white", connections: [25]),
            square(position: 30, occupant: "white", connections: [25, 26]),
            square(position: 31, occupant: "white", connections: [26, 27]),
            square(position: 32, occupant: "white", connections: [27, 28])
          ]
        end
      end

      context "when only one jump step is required to complete a turn and there are no forward facing enemies" do
        before do
          player_one.steps.create!(kind: :simple, from: 12, to: 16)
          player_one.steps.create!(kind: :simple, from: 16, to: 19)
          player_one.steps.create!(kind: :simple, from: 10, to: 14)
          player_one.steps.create!(kind: :simple, from: 11, to: 16)
        end

        let(:steps) { [player_two.steps.create!(kind: :jump, from: 24, to: 15)] }

        it "applies the step and returns the new game state without errors" do
          service = TakeTurn.new(game_state: base_game_state, player: player_two, steps: steps)
          service.call

          expect(service.errors).to be_empty
          expect(service.game_state.current_player).to eq player_one
          expect(service.game_state.board.layout).to eql [
            square(position: 1, occupant: "red", connections: [5, 6]),
            square(position: 2, occupant: "red", connections: [6, 7]),
            square(position: 3, occupant: "red", connections: [7, 8]),
            square(position: 4, occupant: "red", connections: [8]),
            square(position: 5, occupant: "red", connections: [1, 9]),
            square(position: 6, occupant: "red", connections: [1, 2, 9, 10]),
            square(position: 7, occupant: "red", connections: [2, 3, 10, 11]),
            square(position: 8, occupant: "red", connections: [3, 4, 11, 12]),
            square(position: 9, occupant: "red", connections: [5, 6, 13, 14]),
            square(position: 10, occupant: "empty", connections: [6, 7, 14, 15]),
            square(position: 11, occupant: "empty", connections: [7, 8, 15, 16]),
            square(position: 12, occupant: "empty", connections: [8, 16]),
            square(position: 13, occupant: "empty", connections: [9, 17]),
            square(position: 14, occupant: "red", connections: [9, 10, 17, 18]),
            square(position: 15, occupant: "white", connections: [10, 11, 18, 19]),
            square(position: 16, occupant: "red", connections: [11, 12, 19, 20]),
            square(position: 17, occupant: "empty", connections: [13, 14, 21, 22]),
            square(position: 18, occupant: "empty", connections: [14, 15, 22, 23]),
            square(position: 19, occupant: "empty", connections: [15, 16, 23, 24]),
            square(position: 20, occupant: "empty", connections: [16, 24]),
            square(position: 21, occupant: "white", connections: [17, 25]),
            square(position: 22, occupant: "white", connections: [17, 18, 25, 26]),
            square(position: 23, occupant: "white", connections: [18, 19, 26, 27]),
            square(position: 24, occupant: "empty", connections: [19, 20, 27, 28]),
            square(position: 25, occupant: "white", connections: [21, 22, 29, 30]),
            square(position: 26, occupant: "white", connections: [22, 23, 30, 31]),
            square(position: 27, occupant: "white", connections: [23, 24, 31, 32]),
            square(position: 28, occupant: "white", connections: [24, 32]),
            square(position: 29, occupant: "white", connections: [25]),
            square(position: 30, occupant: "white", connections: [25, 26]),
            square(position: 31, occupant: "white", connections: [26, 27]),
            square(position: 32, occupant: "white", connections: [27, 28])
          ]
        end
      end

      context "when multiple jump steps are required to complete a turn" do
        before do
          player_one.steps.create!(kind: :simple, from: 12, to: 16)
          player_one.steps.create!(kind: :simple, from: 16, to: 19)
          player_one.steps.create!(kind: :simple, from: 8, to: 12)
        end

        context "when all the available jumps are taken" do
          let(:steps) { [player_two.steps.create!(kind: :jump, from: 24, to: 15), player_two.steps.create!(kind: :jump, from: 15, to: 8)] }

          it "applies the step and returns the new game state without errors" do
            service = TakeTurn.new(game_state: base_game_state, player: player_two, steps: steps)
            service.call

            expect(service.errors).to be_empty
            expect(service.game_state.current_player).to eq player_one
            expect(service.game_state.board.layout).to eql [
              square(position: 1, occupant: "red", connections: [5, 6]),
              square(position: 2, occupant: "red", connections: [6, 7]),
              square(position: 3, occupant: "red", connections: [7, 8]),
              square(position: 4, occupant: "red", connections: [8]),
              square(position: 5, occupant: "red", connections: [1, 9]),
              square(position: 6, occupant: "red", connections: [1, 2, 9, 10]),
              square(position: 7, occupant: "red", connections: [2, 3, 10, 11]),
              square(position: 8, occupant: "white", connections: [3, 4, 11, 12]),
              square(position: 9, occupant: "red", connections: [5, 6, 13, 14]),
              square(position: 10, occupant: "red", connections: [6, 7, 14, 15]),
              square(position: 11, occupant: "empty", connections: [7, 8, 15, 16]),
              square(position: 12, occupant: "red", connections: [8, 16]),
              square(position: 13, occupant: "empty", connections: [9, 17]),
              square(position: 14, occupant: "empty", connections: [9, 10, 17, 18]),
              square(position: 15, occupant: "empty", connections: [10, 11, 18, 19]),
              square(position: 16, occupant: "empty", connections: [11, 12, 19, 20]),
              square(position: 17, occupant: "empty", connections: [13, 14, 21, 22]),
              square(position: 18, occupant: "empty", connections: [14, 15, 22, 23]),
              square(position: 19, occupant: "empty", connections: [15, 16, 23, 24]),
              square(position: 20, occupant: "empty", connections: [16, 24]),
              square(position: 21, occupant: "white", connections: [17, 25]),
              square(position: 22, occupant: "white", connections: [17, 18, 25, 26]),
              square(position: 23, occupant: "white", connections: [18, 19, 26, 27]),
              square(position: 24, occupant: "empty", connections: [19, 20, 27, 28]),
              square(position: 25, occupant: "white", connections: [21, 22, 29, 30]),
              square(position: 26, occupant: "white", connections: [22, 23, 30, 31]),
              square(position: 27, occupant: "white", connections: [23, 24, 31, 32]),
              square(position: 28, occupant: "white", connections: [24, 32]),
              square(position: 29, occupant: "white", connections: [25]),
              square(position: 30, occupant: "white", connections: [25, 26]),
              square(position: 31, occupant: "white", connections: [26, 27]),
              square(position: 32, occupant: "white", connections: [27, 28])
            ]
          end
        end

        context "when more jumps are still pending" do
          let(:steps) { [player_two.steps.create!(kind: :jump, from: 24, to: 15)] }

          it "applies the step, but keeps curent player same and returns an error" do
            service = TakeTurn.new(game_state: base_game_state, player: player_two, steps: steps)
            service.call

            expect(service.errors).to eq ["You must make all available jumps to complete your turn"]
            expect(service.game_state.current_player).to eq player_two
            expect(service.game_state.board.layout).to eql [
              square(position: 1, occupant: "red", connections: [5, 6]),
              square(position: 2, occupant: "red", connections: [6, 7]),
              square(position: 3, occupant: "red", connections: [7, 8]),
              square(position: 4, occupant: "red", connections: [8]),
              square(position: 5, occupant: "red", connections: [1, 9]),
              square(position: 6, occupant: "red", connections: [1, 2, 9, 10]),
              square(position: 7, occupant: "red", connections: [2, 3, 10, 11]),
              square(position: 8, occupant: "empty", connections: [3, 4, 11, 12]),
              square(position: 9, occupant: "red", connections: [5, 6, 13, 14]),
              square(position: 10, occupant: "red", connections: [6, 7, 14, 15]),
              square(position: 11, occupant: "red", connections: [7, 8, 15, 16]),
              square(position: 12, occupant: "red", connections: [8, 16]),
              square(position: 13, occupant: "empty", connections: [9, 17]),
              square(position: 14, occupant: "empty", connections: [9, 10, 17, 18]),
              square(position: 15, occupant: "white", connections: [10, 11, 18, 19]),
              square(position: 16, occupant: "empty", connections: [11, 12, 19, 20]),
              square(position: 17, occupant: "empty", connections: [13, 14, 21, 22]),
              square(position: 18, occupant: "empty", connections: [14, 15, 22, 23]),
              square(position: 19, occupant: "empty", connections: [15, 16, 23, 24]),
              square(position: 20, occupant: "empty", connections: [16, 24]),
              square(position: 21, occupant: "white", connections: [17, 25]),
              square(position: 22, occupant: "white", connections: [17, 18, 25, 26]),
              square(position: 23, occupant: "white", connections: [18, 19, 26, 27]),
              square(position: 24, occupant: "empty", connections: [19, 20, 27, 28]),
              square(position: 25, occupant: "white", connections: [21, 22, 29, 30]),
              square(position: 26, occupant: "white", connections: [22, 23, 30, 31]),
              square(position: 27, occupant: "white", connections: [23, 24, 31, 32]),
              square(position: 28, occupant: "white", connections: [24, 32]),
              square(position: 29, occupant: "white", connections: [25]),
              square(position: 30, occupant: "white", connections: [25, 26]),
              square(position: 31, occupant: "white", connections: [26, 27]),
              square(position: 32, occupant: "white", connections: [27, 28])
            ]
          end
        end
      end
    end

    context "when the player is not allowed to move" do
      let(:steps) { [player_two.steps.create!(kind: :simple, from: 24, to: 20)] }

      it "does not alter the game state and returns an error" do
        service = TakeTurn.new(game_state: base_game_state, player: player_two, steps: steps)
        service.call

        expect(service.errors).to eq ["It's not your turn right now!"]
        expect(service.game_state.current_player).to eq player_one
        expect(service.game_state).to eq base_game_state
      end
    end
  end
end

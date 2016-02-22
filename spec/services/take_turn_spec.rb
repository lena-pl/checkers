require 'rails_helper'

RSpec.describe TakeTurn do
  let!(:game) { Game.create! }
  let!(:player_one) { game.players.create!(colour: :red) }
  let!(:player_two) { game.players.create!(colour: :white) }

  let(:base_game_state) { BuildGameState.new(game).call }

  describe "#call" do
    context "when the player is allowed to move" do
      context "when only 1 step is taken" do
        let(:steps) { [player_one.steps.create!(kind: :simple, from: 12, to: 16)] }

        it "applies the step and returns the new game state without errors" do
          service = TakeTurn.new(game_state: base_game_state, player_colour: player_one.colour, steps: steps)
          service.call

          expect(service.errors).to be_empty
          expect(service.game_state.current_player).to eq player_two
          expect(service.game_state.board.layout).to eql [Board::Square.new(1, "red", [5, 6]), Board::Square.new(2, "red", [6, 7]), Board::Square.new(3, "red", [7, 8]), Board::Square.new(4, "red", [8]), Board::Square.new(5, "red", [1, 9]), Board::Square.new(6, "red", [1, 2, 9, 10]), Board::Square.new(7, "red", [2, 3, 10, 11]), Board::Square.new(8, "red", [3, 4, 11, 12]), Board::Square.new(9, "red", [5, 6, 13, 14]), Board::Square.new(10, "red", [6, 7, 14, 15]), Board::Square.new(11, "red", [7, 8, 15, 16]), Board::Square.new(12, "empty", [8, 16]), Board::Square.new(13, "empty", [9, 17]), Board::Square.new(14, "empty", [9, 10, 17, 18]), Board::Square.new(15, "empty", [10, 11, 18, 19]), Board::Square.new(16, "red", [11, 12, 19, 20]), Board::Square.new(17, "empty", [13, 14, 21, 22]), Board::Square.new(18, "empty", [14, 15, 22, 23]), Board::Square.new(19, "empty", [15, 16, 23, 24]), Board::Square.new(20, "empty", [16, 24]), Board::Square.new(21, "white", [17, 25]), Board::Square.new(22, "white", [17, 18, 25, 26]), Board::Square.new(23, "white", [18, 19, 26, 27]), Board::Square.new(24, "white", [19, 20, 27, 28]), Board::Square.new(25, "white", [21, 22, 29, 30]), Board::Square.new(26, "white", [22, 23, 30, 31]), Board::Square.new(27, "white", [23, 24, 31, 32]), Board::Square.new(28, "white", [24, 32]), Board::Square.new(29, "white", [25]), Board::Square.new(30, "white", [25, 26]), Board::Square.new(31, "white", [26, 27]), Board::Square.new(32, "white", [27, 28])]
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
          service = TakeTurn.new(game_state: base_game_state, player_colour: player_two.colour, steps: steps)
          service.call

          expect(service.errors).to be_empty
          expect(service.game_state.current_player).to eq player_one
          expect(service.game_state.board.layout).to eql [Board::Square.new(1, "red", [5, 6]), Board::Square.new(2, "red", [6, 7]), Board::Square.new(3, "red", [7, 8]), Board::Square.new(4, "red", [8]), Board::Square.new(5, "red", [1, 9]), Board::Square.new(6, "red", [1, 2, 9, 10]), Board::Square.new(7, "red", [2, 3, 10, 11]), Board::Square.new(8, "red", [3, 4, 11, 12]), Board::Square.new(9, "red", [5, 6, 13, 14]), Board::Square.new(10, "empty", [6, 7, 14, 15]), Board::Square.new(11, "empty", [7, 8, 15, 16]), Board::Square.new(12, "empty", [8, 16]), Board::Square.new(13, "empty", [9, 17]), Board::Square.new(14, "red", [9, 10, 17, 18]), Board::Square.new(15, "white", [10, 11, 18, 19]), Board::Square.new(16, "red", [11, 12, 19, 20]), Board::Square.new(17, "empty", [13, 14, 21, 22]), Board::Square.new(18, "empty", [14, 15, 22, 23]), Board::Square.new(19, "empty", [15, 16, 23, 24]), Board::Square.new(20, "empty", [16, 24]), Board::Square.new(21, "white", [17, 25]), Board::Square.new(22, "white", [17, 18, 25, 26]), Board::Square.new(23, "white", [18, 19, 26, 27]), Board::Square.new(24, "empty", [19, 20, 27, 28]), Board::Square.new(25, "white", [21, 22, 29, 30]), Board::Square.new(26, "white", [22, 23, 30, 31]), Board::Square.new(27, "white", [23, 24, 31, 32]), Board::Square.new(28, "white", [24, 32]), Board::Square.new(29, "white", [25]), Board::Square.new(30, "white", [25, 26]), Board::Square.new(31, "white", [26, 27]), Board::Square.new(32, "white", [27, 28])]
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
            service = TakeTurn.new(game_state: base_game_state, player_colour: player_two.colour, steps: steps)
            service.call

            expect(service.errors).to be_empty
            expect(service.game_state.current_player).to eq player_one
            expect(service.game_state.board.layout).to eql [Board::Square.new(1, "red", [5, 6]), Board::Square.new(2, "red", [6, 7]), Board::Square.new(3, "red", [7, 8]), Board::Square.new(4, "red", [8]), Board::Square.new(5, "red", [1, 9]), Board::Square.new(6, "red", [1, 2, 9, 10]), Board::Square.new(7, "red", [2, 3, 10, 11]), Board::Square.new(8, "white", [3, 4, 11, 12]), Board::Square.new(9, "red", [5, 6, 13, 14]), Board::Square.new(10, "red", [6, 7, 14, 15]), Board::Square.new(11, "empty", [7, 8, 15, 16]), Board::Square.new(12, "red", [8, 16]), Board::Square.new(13, "empty", [9, 17]), Board::Square.new(14, "empty", [9, 10, 17, 18]), Board::Square.new(15, "empty", [10, 11, 18, 19]), Board::Square.new(16, "empty", [11, 12, 19, 20]), Board::Square.new(17, "empty", [13, 14, 21, 22]), Board::Square.new(18, "empty", [14, 15, 22, 23]), Board::Square.new(19, "empty", [15, 16, 23, 24]), Board::Square.new(20, "empty", [16, 24]), Board::Square.new(21, "white", [17, 25]), Board::Square.new(22, "white", [17, 18, 25, 26]), Board::Square.new(23, "white", [18, 19, 26, 27]), Board::Square.new(24, "empty", [19, 20, 27, 28]), Board::Square.new(25, "white", [21, 22, 29, 30]), Board::Square.new(26, "white", [22, 23, 30, 31]), Board::Square.new(27, "white", [23, 24, 31, 32]), Board::Square.new(28, "white", [24, 32]), Board::Square.new(29, "white", [25]), Board::Square.new(30, "white", [25, 26]), Board::Square.new(31, "white", [26, 27]), Board::Square.new(32, "white", [27, 28])]
          end
        end

        context "when more jumps are still pending" do
          let(:steps) { [player_two.steps.create!(kind: :jump, from: 24, to: 15)] }

          it "applies the step, but keeps curent player same and returns an error" do
            service = TakeTurn.new(game_state: base_game_state, player_colour: player_two.colour, steps: steps)
            service.call

            expect(service.errors).to eq ["You must make all available jumps to complete your turn"]
            expect(service.game_state.current_player).to eq player_two
            expect(service.game_state.board.layout).to eql [Board::Square.new(1, "red", [5, 6]), Board::Square.new(2, "red", [6, 7]), Board::Square.new(3, "red", [7, 8]), Board::Square.new(4, "red", [8]), Board::Square.new(5, "red", [1, 9]), Board::Square.new(6, "red", [1, 2, 9, 10]), Board::Square.new(7, "red", [2, 3, 10, 11]), Board::Square.new(8, "empty", [3, 4, 11, 12]), Board::Square.new(9, "red", [5, 6, 13, 14]), Board::Square.new(10, "red", [6, 7, 14, 15]), Board::Square.new(11, "red", [7, 8, 15, 16]), Board::Square.new(12, "red", [8, 16]), Board::Square.new(13, "empty", [9, 17]), Board::Square.new(14, "empty", [9, 10, 17, 18]), Board::Square.new(15, "white", [10, 11, 18, 19]), Board::Square.new(16, "empty", [11, 12, 19, 20]), Board::Square.new(17, "empty", [13, 14, 21, 22]), Board::Square.new(18, "empty", [14, 15, 22, 23]), Board::Square.new(19, "empty", [15, 16, 23, 24]), Board::Square.new(20, "empty", [16, 24]), Board::Square.new(21, "white", [17, 25]), Board::Square.new(22, "white", [17, 18, 25, 26]), Board::Square.new(23, "white", [18, 19, 26, 27]), Board::Square.new(24, "empty", [19, 20, 27, 28]), Board::Square.new(25, "white", [21, 22, 29, 30]), Board::Square.new(26, "white", [22, 23, 30, 31]), Board::Square.new(27, "white", [23, 24, 31, 32]), Board::Square.new(28, "white", [24, 32]), Board::Square.new(29, "white", [25]), Board::Square.new(30, "white", [25, 26]), Board::Square.new(31, "white", [26, 27]), Board::Square.new(32, "white", [27, 28])]
          end
        end
      end
    end

    context "when the player is not allowed to move" do
      let(:steps) { [player_two.steps.create!(kind: :simple, from: 24, to: 20)] }

      it "does not alter the game state and returns an error" do
        service = TakeTurn.new(game_state: base_game_state, player_colour: player_two.colour, steps: steps)
        service.call

        expect(service.errors).to eq ["It's not your turn right now!"]
        expect(service.game_state.current_player).to eq player_one
        expect(service.game_state).to eq base_game_state
      end
    end
  end
end

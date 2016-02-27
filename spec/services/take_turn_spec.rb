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
          expect(board_layout_as_string(service.game_state.board.layout)).to eql <<-BOARD.strip_heredoc
            .r.r.r.r
            r.r.r.r.
            .r.r.r._
            _._._.r.
            ._._._._
            w.w.w.w.
            .w.w.w.w
            w.w.w.w.
          BOARD
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
          expect(board_layout_as_string(service.game_state.board.layout)).to eql <<-BOARD.strip_heredoc
            .r.r.r.r
            r.r.r.r.
            .r._._._
            _.r.w.r.
            ._._._._
            w.w.w._.
            .w.w.w.w
            w.w.w.w.
          BOARD
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
            expect(board_layout_as_string(service.game_state.board.layout)).to eql <<-BOARD.strip_heredoc
              .r.r.r.r
              r.r.r.w.
              .r.r._.r
              _._._._.
              ._._._._
              w.w.w._.
              .w.w.w.w
              w.w.w.w.
            BOARD
          end
        end

        context "when more jumps are still pending" do
          let(:steps) { [player_two.steps.create!(kind: :jump, from: 24, to: 15)] }

          it "applies the step, but keeps curent player same and returns an error" do
            service = TakeTurn.new(game_state: base_game_state, player: player_two, steps: steps)
            service.call

            expect(service.errors).to eq ["You still have more jumps available! Complete the path to end your turn."]
            expect(service.game_state.current_player).to eq player_two
            expect(board_layout_as_string(service.game_state.board.layout)).to eql <<-BOARD.strip_heredoc
              .r.r.r.r
              r.r.r._.
              .r.r.r.r
              _._.w._.
              ._._._._
              w.w.w._.
              .w.w.w.w
              w.w.w.w.
            BOARD
          end
        end
      end

      context "when the player jumps onto the row immediately preceeding king's row and there is an adjacent enemy ahead" do
        before do
          player_one.steps.create!(kind: :simple, from: 12, to: 16)
          player_two.steps.create!(kind: :simple, from: 23, to: 18)

          player_one.steps.create!(kind: :simple, from: 8, to: 12)
          player_two.steps.create!(kind: :simple, from: 18, to: 15)

          player_one.steps.create!(kind: :simple, from: 16, to: 19)
        end

        let(:steps) { [player_two.steps.create!(kind: :jump, from: 15, to: 8)] }

        it "completes the turn and hands it over to the other player" do
          service = TakeTurn.new(game_state: base_game_state, player: player_two, steps: steps)
          service.call

          expect(service.errors).to be_empty
          expect(service.game_state.current_player).to eq player_one
          expect(board_layout_as_string(service.game_state.board.layout)).to eql <<-BOARD.strip_heredoc
            .r.r.r.r
            r.r.r.w.
            .r.r._.r
            _._._._.
            ._._.r._
            w.w._.w.
            .w.w.w.w
            w.w.w.w.
          BOARD
        end
      end

      context "when a piece jumps into a row adjacent to the edge of the board and has an adjacent enemy ahead" do
        before do
          player_one.steps.create!(kind: :simple, from: 11, to: 15)
          player_two.steps.create!(kind: :simple, from: 23, to: 18)

          player_one.steps.create!(kind: :simple, from: 15, to: 19)
          player_two.steps.create!(kind: :simple, from: 27, to: 23)

          player_one.steps.create!(kind: :simple, from: 10, to: 15)
          player_two.steps.create!(kind: :simple, from: 18, to: 14)

          player_one.steps.create!(kind: :simple, from: 15, to: 18)
          player_two.steps.create!(kind: :simple, from: 14, to: 10)

          player_one.steps.create!(kind: :jump, from: 18, to: 27)
        end

        let(:steps) { [player_two.steps.create!(kind: :jump, from: 32, to: 23), player_two.steps.create!(kind: :jump, from: 23, to: 16)] }

        it "completes the turn and finds the next player" do
          service = TakeTurn.new(game_state: base_game_state, player: player_two, steps: steps)
          service.call

          expect(service.errors).to be_empty
          expect(service.game_state.current_player).to eq player_one
          expect(board_layout_as_string(service.game_state.board.layout)).to eql <<-BOARD.strip_heredoc
            .r.r.r.r
            r.r.r.r.
            .r.w._.r
            _._._.w.
            ._._._._
            w.w._.w.
            .w.w._.w
            w.w.w._.
          BOARD
        end
      end

      context "when multiple jumps are available, but the piece has been crowned during the turn" do
        before do
          player_one.steps.create!(kind: :simple, from: 12, to: 16)
          player_two.steps.create!(kind: :simple, from: 21, to: 17)

          player_one.steps.create!(kind: :simple, from: 8, to: 12)
          player_two.steps.create!(kind: :simple, from: 17, to: 14)

          player_one.steps.create!(kind: :simple, from: 3, to: 8)
          player_two.steps.create!(kind: :simple, from: 22, to: 17)

          player_one.steps.create!(kind: :simple, from: 10, to: 15)
          player_two.steps.create!(kind: :simple, from: 14, to: 10)

          player_one.steps.create!(kind: :simple, from: 16, to: 20)
          player_two.steps.create!(kind: :simple, from: 26, to: 22)

          player_one.steps.create!(kind: :simple, from: 12, to: 16)
        end

        let(:steps) { [player_two.steps.create!(kind: :jump, from: 10, to: 3)] }

        it "hands the turn over to the other player immediately after crowning" do
          service = TakeTurn.new(game_state: base_game_state, player: player_two, steps: steps)
          service.call

          expect(service.errors).to be_empty
          expect(service.game_state.current_player).to eq player_one
          expect(board_layout_as_string(service.game_state.board.layout)).to eql <<-BOARD.strip_heredoc
            .r.r.W.r
            r.r._.r.
            .r._.r._
            _._.r.r.
            .w._._.r
            _.w.w.w.
            .w._.w.w
            w.w.w.w.
          BOARD
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

    context "when a piece reaches king's row during the most recent step of the turn" do
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
      end

      let(:steps) { [player_one.steps.create!(kind: :jump, from: 23, to: 32)] }

      it "gets the board to crown the piece" do
        service = TakeTurn.new(game_state: base_game_state, player: player_one, steps: steps)
        service.call

        expect(service.errors).to be_empty
        expect(service.game_state.current_player).to eq player_two
        expect(board_layout_as_string(service.board.layout)).to eql <<-BOARD.strip_heredoc
          .r.r.r.r
          r.r.r._.
          .w._._.r
          r._.r._.
          .r._._._
          w.w._.w.
          .w.w._.w
          w.w.w.R.
        BOARD
        expect(service.board.square_occupant(steps.last.to).rank).to eq "king"
      end
    end
  end
end

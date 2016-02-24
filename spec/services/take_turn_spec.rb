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
          expect(board_layout_as_string(service.game_state.board.layout)).to eql <<-BOARD.gsub(/^ {12}/, '')
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
          expect(board_layout_as_string(service.game_state.board.layout)).to eql <<-BOARD.gsub(/^ {12}/, '')
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
            expect(board_layout_as_string(service.game_state.board.layout)).to eql <<-BOARD.gsub(/^ {14}/, '')
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

            expect(service.errors).to eq ["You must make all available jumps to complete your turn"]
            expect(service.game_state.current_player).to eq player_two
            expect(board_layout_as_string(service.game_state.board.layout)).to eql <<-BOARD.gsub(/^ {14}/, '')
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

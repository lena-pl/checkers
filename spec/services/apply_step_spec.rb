require 'rails_helper'
require_relative '../support/board_helpers'

RSpec.describe ApplyStep do
  include BoardHelpers

  let(:squares) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "red"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "empty"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "white"], [25, "white"], [26, "white"], [27, "white"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "white"]] }
  let(:board) { Board.new(squares) }

  let(:game) { Game.create! }
  let(:player_one) { game.players.create!(colour: :red) }
  let(:player_two) { game.players.create!(colour: :white) }

  describe "#call" do
    context "when the step is a simple step" do
      let(:step) { player_one.steps.create!(kind: :simple, from: 12, to: 16) }

      it "applies the step and returns the board in its new state" do
        service = ApplyStep.new(board, step)
        service.call

        expect(board_layout_as_string(service.board.layout)).to eql <<-BOARD.strip_heredoc
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

    context "when the step is a jump step" do
      let(:squares) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "empty"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "red"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "white"], [25, "white"], [26, "white"], [27, "white"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "white"]] }

      let(:step) { player_two.steps.create!(kind: :jump, from: 24, to: 15) }

      it "applies the step and returns the board in its new state" do
        service = ApplyStep.new(board, step)
        service.call

        expect(board_layout_as_string(service.board.layout)).to eql <<-BOARD.strip_heredoc
          .r.r.r.r
          r.r.r.r.
          .r.r.r._
          _._.w._.
          ._._._._
          w.w.w._.
          .w.w.w.w
          w.w.w.w.
        BOARD
      end
    end

    context "when the piece reaches king's row on move completion" do
      let(:squares) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "empty"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "empty"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "white"], [25, "white"], [26, "white"], [27, "red"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "empty"]] }

      let(:step) { player_one.steps.create!(kind: :simple, from: 27, to: 32) }

      it "gets the board to crown the piece" do
        service = ApplyStep.new(board, step)
        service.call

        expect(service.board.square_occupant(step.to).rank).to eq "king"
      end
    end
  end
end

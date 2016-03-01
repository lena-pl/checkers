require 'rails_helper'
require_relative '../support/board_helpers'

RSpec.describe ConstructBoard do
  include BoardHelpers

  let(:positions_and_occupants) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "red"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "empty"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "white"], [25, "white"], [26, "white"], [27, "white"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "white"]] }
  subject { Board.new(positions_and_occupants) }
  let(:game) { Game.create! }
  let(:player_one) { game.players.create!(colour: :red) }
  let(:player_two) { game.players.create!(colour: :white) }

  describe "#call" do
    it "returns an array of square structs with correct positions, connections and occupants" do
      expect(board_layout_as_string(subject.layout)).to eql <<-BOARD.strip_heredoc
        .r.r.r.r
        r.r.r.r.
        .r.r.r.r
        _._._._.
        ._._._._
        w.w.w.w.
        .w.w.w.w
        w.w.w.w.
      BOARD

      expect(subject.layout).to eql [
        square(1, "red", [5, 6], [10]),
        square(2, "red", [6, 7], [9, 11]),
        square(3, "red", [7, 8], [10, 12]),
        square(4, "red", [8], [11]),
        square(5, "red", [1, 9], [14]),
        square(6, "red", [1, 2, 9, 10], [13, 15]),
        square(7, "red", [2, 3, 10, 11], [14, 16]),
        square(8, "red", [3, 4, 11, 12], [15]),
        square(9, "red", [5, 6, 13, 14], [2, 18]),
        square(10, "red", [6, 7, 14, 15], [1, 3, 17, 19]),
        square(11, "red", [7, 8, 15, 16], [2, 4, 18, 20]),
        square(12, "red", [8, 16], [3, 19]),
        square(13, "empty", [9, 17], [6, 22]),
        square(14, "empty", [9, 10, 17, 18], [5, 7, 21, 23]),
        square(15, "empty", [10, 11, 18, 19], [6, 8, 22, 24]),
        square(16, "empty", [11, 12, 19, 20], [7, 23]),
        square(17, "empty", [13, 14, 21, 22], [10, 26]),
        square(18, "empty", [14, 15, 22, 23], [9, 11, 25, 27]),
        square(19, "empty", [15, 16, 23, 24], [10, 12, 26, 28]),
        square(20, "empty", [16, 24], [11, 27]),
        square(21, "white", [17, 25], [14, 30]),
        square(22, "white", [17, 18, 25, 26], [13, 15, 29, 31]),
        square(23, "white", [18, 19, 26, 27], [14, 16, 30, 32]),
        square(24, "white", [19, 20, 27, 28], [15, 31]),
        square(25, "white", [21, 22, 29, 30], [18]),
        square(26, "white", [22, 23, 30, 31], [17, 19]),
        square(27, "white", [23, 24, 31, 32], [18, 20]),
        square(28, "white", [24, 32], [19]),
        square(29, "white", [25], [22]),
        square(30, "white", [25, 26], [21, 23]),
        square(31, "white", [26, 27], [22, 24]),
        square(32, "white", [27, 28], [23])
      ]
    end
  end
end

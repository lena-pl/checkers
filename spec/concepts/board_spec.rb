require 'rails_helper'
require_relative '../support/board_helpers'

RSpec.describe Board do
  include BoardHelpers

  let(:squares) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "red"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "empty"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "white"], [25, "white"], [26, "white"], [27, "white"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "white"]] }
  subject { Board.new(squares) }
  let(:game) { Game.create! }
  let(:player_one) { game.players.create!(colour: :red) }
  let(:player_two) { game.players.create!(colour: :white) }

  describe "#layout" do
    it "returns an array of square structs with correct positions, connections and occupants" do
      expect(subject.layout).to eql [
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

  describe "#square_occupant" do
    it "returns the correct square occupant, given a checker board position" do
      square_four = square(position: squares[3][0], occupant: squares[3][1], connections: [8])

      expect(subject.square_occupant(4)).to eq square_four.occupant
    end
  end

  describe "#square_connections" do
    it "returns the correct square connections, given a checker board position" do
      square_four = square(position: squares[3][0], occupant: squares[3][1], connections: [8])

      expect(subject.square_connections(4)).to eq square_four.connections
    end
  end

  describe "#player_pieces" do
    it "returns all the pieces currently on the board for a given player" do
      expect(subject.player_pieces(player_one)).to eq [
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
        square(position: 12, occupant: "red", connections: [8, 16])
      ]
    end
  end

  describe "#capture_piece" do
    it "captures a piece in a given position" do
      square_ten = square(position: squares[9][0], occupant: squares[9][1], connections: [6, 7, 14, 15])

      subject.capture_piece(10)

      expect(subject.square_occupant(10)).to eq nil

      expect(subject.layout).to eql [
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
        square(position: 11, occupant: "red", connections: [7, 8, 15, 16]),
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

  describe "#move_piece" do
    it "moves a piece from a given position to another given position, updating the board layout" do
      square_ten = square(position: squares[9][0], occupant: squares[9][1], connections: [6, 7, 14, 15])

      subject.move_piece(10, 15)

      expect(subject.square_occupant(10)).to eq nil
      expect(subject.square_occupant(15)).to eq square_ten.occupant

      expect(subject.layout).to eql [
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
        square(position: 11, occupant: "red", connections: [7, 8, 15, 16]),
        square(position: 12, occupant: "red", connections: [8, 16]),
        square(position: 13, occupant: "empty", connections: [9, 17]),
        square(position: 14, occupant: "empty", connections: [9, 10, 17, 18]),
        square(position: 15, occupant: "red", connections: [10, 11, 18, 19]),
        square(position: 16, occupant: "empty", connections: [11, 12, 19, 20]),
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
end

require 'rails_helper'

RSpec.describe BuildGameState do
  let!(:game) { Game.create! }
  let!(:player_one) { game.players.create!(colour: :red) }
  let!(:player_two) { game.players.create!(colour: :white) }

  describe "#call" do
    context "when a player only took one legal step" do
      before do
        player_one.steps.create!(kind: :simple, from: 12, to: 16)
      end

      it "returns no errors" do
        service = BuildGameState.new(game)
        service.call

        expect(service.errors).to be_empty
      end

      it "changes the current player in the new game state" do
        service = BuildGameState.new(game)

        expect(service.call.current_player).to eq player_two
      end

      it "applies changes to the board in the new game state" do
        service = BuildGameState.new(game)

        expect(service.call.board.square_occupant(12)).to be_nil
        expect(service.call.board.square_occupant(16).colour).to eq "red"
      end
    end

    context "when a player took multiple consecutive legal steps" do
      before do
        player_one.steps.create!(kind: :simple, from: 11, to: 15)
        player_two.steps.create!(kind: :simple, from: 21, to: 17)

        player_one.steps.create!(kind: :simple, from: 15, to: 18)
        player_two.steps.create!(kind: :simple, from: 24, to: 20)

        player_one.steps.create!(kind: :simple, from: 8, to: 11)

        player_two.steps.create!(kind: :jump, from: 22, to: 15)
        player_two.steps.create!(kind: :jump, from: 15, to: 8)
      end

      it "returns no errors" do
        service = BuildGameState.new(game)
        service.call

        expect(service.errors).to be_empty
      end

      it "changes the current player in the new game state" do
        service = BuildGameState.new(game)

        expect(service.call.current_player).to eq player_one
      end

      it "applies all turn changes to the board in the new game state" do
        service = BuildGameState.new(game)

        expect(service.call.board.square_occupant(22)).to be_nil
        expect(service.call.board.square_occupant(8).colour).to eq "white"
      end
    end

    describe "when a player tries to take an illegal step" do
      it "returns not your turn error if wrong player" do
        player_two.steps.create!(kind: :simple, from: 23, to: 18)

        service = BuildGameState.new(game)
        service.call

        expect(service.errors).to eq ["It's not your turn right now!"]
      end
    end
  end
end

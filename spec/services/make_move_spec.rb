require 'rails_helper'

RSpec.describe MakeMove do
  let(:positions_and_occupants) { [[1, "red"], [2, "red"], [3, "red"], [4, "red"], [5, "red"], [6, "red"], [7, "red"], [8, "red"], [9, "red"], [10, "red"], [11, "red"], [12, "red"], [13, "empty"], [14, "empty"], [15, "empty"], [16, "empty"], [17, "empty"], [18, "empty"], [19, "empty"], [20, "empty"], [21, "white"], [22, "white"], [23, "white"], [24, "white"], [25, "white"], [26, "white"], [27, "white"], [28, "white"], [29, "white"], [30, "white"], [31, "white"], [32, "white"]] }
  let(:board) { Board.new(positions_and_occupants) }

  let(:game) { Game.create! }
  let(:player_one) { game.players.create!(colour: :red) }
  let(:player_two) { game.players.create!(colour: :white) }

  describe "#call" do
    context "when a piece is at the end of a jump path, has an adjacent enemy and an empty square in the wrong horizontal direction" do
      before do
        player_one.steps.create!(kind: :simple, from: 11, to: 16)
        player_two.steps.create!(kind: :simple, from: 21, to: 17)

        player_one.steps.create!(kind: :simple, from: 7, to: 11)
        player_two.steps.create!(kind: :simple, from: 17, to: 14)

        player_one.steps.create!(kind: :simple, from: 9, to: 13)
        player_two.steps.create!(kind: :simple, from: 14, to: 7)

        player_one.steps.create!(kind: :simple, from: 16, to: 19)
        player_two.steps.create!(kind: :simple, from: 22, to: 17)

        player_one.steps.create!(kind: :simple, from: 5, to: 9)
        player_two.steps.create!(kind: :simple, from: 17, to: 14)

        player_one.steps.create!(kind: :simple, from: 1, to: 5)
        player_two.steps.create!(kind: :simple, from: 25, to: 21)

        player_one.steps.create!(kind: :jump, from: 3, to: 10)
      end

      let(:board) { BuildGameState.new(game).call.board }

      context "when a player tries to make a simple step" do
        let(:from) { 10 }
        let(:to) { 15 }

        it "returns false" do
          service = MakeMove.new(game, player_one, board, from, to)

          expect(service.call).to eq false
        end

        it "returns correct errors" do
          service = MakeMove.new(game, player_one, board, from, to)
          service.call

          expect(service.errors).to eq ["That's not a valid move!"]
        end
      end

      context "when a player tries to make a jump step" do
        let(:from) { 10 }
        let(:to) { 17 }

        it "returns true" do
          service = MakeMove.new(game, player_one, board, from, to)

          expect(service.call).to eq true
        end

        it "returns no errors" do
          service = MakeMove.new(game, player_one, board, from, to)
          service.call

          expect(service.errors).to eq []
        end
      end
    end

    context 'when a valid simple step is being made' do
      let(:board) { BuildGameState.new(game).call.board }
      let(:from) { 12 }
      let(:to) { 16 }

      it "returns true" do
        service = MakeMove.new(game, player_one, board, from, to)

        expect(service.call).to eq true
      end

      it "returns no errors" do
        service = MakeMove.new(game, player_one, board, from, to)
        service.call

        expect(service.errors).to eq []
      end
    end

    context 'when an invalid simple step is being made' do
      let(:board) { BuildGameState.new(game).call.board }
      let(:from) { 12 }
      let(:to) { 8 }

      it "returns false" do
        service = MakeMove.new(game, player_one, board, from, to)

        expect(service.call).to eq false
      end

      it "returns correct errors" do
        service = MakeMove.new(game, player_one, board, from, to)
        service.call

        expect(service.errors).to eq ["That's not a valid move!"]
      end
    end

    context 'when a valid jump step is being made' do
      before do
        player_one.steps.create!(kind: :simple, from: 12, to: 16)
        player_two.steps.create!(kind: :simple, from: 24, to: 19)
        player_one.steps.create!(kind: :simple, from: 11, to: 15)
      end

      let(:board) { BuildGameState.new(game).call.board }
      let(:from) { 19 }
      let(:to) { 12 }

      it "returns true" do
        service = MakeMove.new(game, player_two, board, from, to)

        expect(service.call).to eq true
      end

      it "returns no errors" do
        service = MakeMove.new(game, player_two, board, from, to)
        service.call

        expect(service.errors).to eq []
      end
    end

    context 'when an invalid jump step is being made' do
      before do
        player_one.steps.create!(kind: :simple, from: 12, to: 16)
        player_two.steps.create!(kind: :simple, from: 24, to: 19)
        player_one.steps.create!(kind: :simple, from: 8, to: 12)
      end

      let(:board) { BuildGameState.new(game).call.board }
      let(:from) { 19 }
      let(:to) { 12 }

      it "returns false" do
        service = MakeMove.new(game, player_two, board, from, to)

        expect(service.call).to eq false
      end

      it "returns correct errors" do
        service = MakeMove.new(game, player_two, board, from, to)
        service.call

        expect(service.errors).to eq ["That's not a valid move!"]
      end
    end

    context "when the player tries to move a piece that does not belong to them" do
      let(:board) { BuildGameState.new(game).call.board }
      let(:from) { 24 }
      let(:to) { 19 }

      it "returns false" do
        service = MakeMove.new(game, player_one, board, from, to)

        expect(service.call).to eq false
      end

      it "returns correct errors" do
        service = MakeMove.new(game, player_one, board, from, to)
        service.call

        expect(service.errors).to eq ["That square doesn't hold one of your pieces!"]
      end
    end
  end
end

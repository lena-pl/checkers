require 'rails_helper'

RSpec.describe StepsController, type: :controller do
  let!(:game) { Game.create! }
  let!(:player_one) { game.players.create!(colour: :red) }
  let!(:player_two) { game.players.create!(colour: :white) }

  describe "POST create" do
    context 'when a valid simple step is being made' do
      it 'does not return errors' do
        post :create, game_id: game, player_id: player_one.id, step: {from: 12, to: 16}

        expect(flash.alert).to be_nil
      end

      it 'applies the step' do
        post :create, game_id: game, player_id: player_one.id, step: {from: 12, to: 16}

        expect(game.steps).not_to be_empty
      end

      it 'redirects to show' do
        post :create, game_id: game, player_id: player_one.id, step: {from: 12, to: 16}

        expect(response).to redirect_to(controller: 'games', action: 'show', id: Game.last.id)
      end
    end

    context 'when an invalid simple step is being made' do
      it 'does not apply the step' do
        post :create, game_id: game, player_id: player_one.id, step: {from: 12, to: 8}

        expect(game.steps).to be_empty
      end

      it 'redirects to show' do
        post :create, game_id: game, player_id: player_one.id, step: {from: 12, to: 8}

        expect(response).to redirect_to(controller: 'games', action: 'show', id: Game.last.id)
      end
    end

    context 'when a valid jump step is being made' do
      before do
        player_one.steps.create!(kind: :simple, from: 12, to: 16)
        player_two.steps.create!(kind: :simple, from: 24, to: 19)
        player_one.steps.create!(kind: :simple, from: 11, to: 15)
      end

      it 'does not return errors' do
        post :create, game_id: game, player_id: player_two.id, step: {from: 19, to: 12}

        expect(flash.alert).to be_nil
      end

      it 'applies the step' do
        post :create, game_id: game, player_id: player_two.id, step: {from: 19, to: 12}

        expect(game.steps.count).to eq 4
      end

      it 'redirects to show' do
        post :create, game_id: game, player_id: player_two.id, step: {from: 19, to: 12}

        expect(response).to redirect_to(controller: 'games', action: 'show', id: Game.last.id)
      end
    end

    context 'when an invalid jump step is being made' do
      before do
        player_one.steps.create!(kind: :simple, from: 12, to: 16)
        player_two.steps.create!(kind: :simple, from: 24, to: 19)
        player_one.steps.create!(kind: :simple, from: 8, to: 12)
      end

      it 'does not apply the step' do
        post :create, game_id: game, player_id: player_two.id, step: {from: 19, to: 12}

        expect(game.steps.count).to eq 3
      end

      it 'redirects to show' do
        post :create, game_id: game, player_id: player_two.id, step: {from: 19, to: 12}

        expect(response).to redirect_to(controller: 'games', action: 'show', id: Game.last.id)
      end
    end

    context "when the player tries to move a piece that does not belong to them" do
      it 'returns the correct errors' do
        post :create, game_id: game, player_id: player_one.id, step: {from: 24, to: 19}

        expect(flash.alert).to eq ["That square doesn't hold one of your pieces!"]
      end

      it 'does not apply the step' do
        post :create, game_id: game, player_id: player_one.id, step: {from: 24, to: 19}

        expect(game.steps).to be_empty
      end

      it 'redirects to show' do
        post :create, game_id: game, player_id: player_one.id, step: {from: 24, to: 19}

        expect(response).to redirect_to(controller: 'games', action: 'show', id: Game.last.id)
      end
    end
  end
end

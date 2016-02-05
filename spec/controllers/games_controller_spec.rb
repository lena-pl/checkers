require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:game) { Game.create! }

  describe "GET new" do
    it "has a 200 status code" do
      get :new

      expect(response.status).to eq 200
    end

    it "assigns @game" do
      get :new

      expect(assigns(:game)).to be_a_new Game
    end

    it "renders the new game template" do
      get :new

      expect(response).to render_template :new
    end
  end

  describe "POST create" do
    context 'after creation' do
      it 'redirects to show' do
        post :create

        expect(response).to redirect_to(controller: 'games', action: 'show', id: Game.last.id)
      end
    end
  end

  describe "GET show" do
    it "assigns @game" do
      get :show, id: game.id

      expect(assigns(:game)).to eq game
    end

    it "renders the show game template" do
      get :show, id: game.id

      expect(response).to render_template :show
    end
  end
end

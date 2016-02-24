class GamesController < ApplicationController
  def new
    @game = Game.new
  end

  def create
    Game.transaction do
      @game = Game.create!
      @game.players.create!(colour: :red)
      @game.players.create!(colour: :white)
    end

    redirect_to @game
  end

  def show
    @game = Game.find(params[:id])
    service = BuildGameState.new(@game)
    @game_state = service.call

    if service.errors.present?
      flash.alert ? flash.alert += service.errors : flash.alert = service.errors
    end
  end
end

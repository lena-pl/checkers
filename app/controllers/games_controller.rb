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
  end
end

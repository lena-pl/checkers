class StepsController < ApplicationController
  def create
    game = Game.find(params[:game_id])
    game_state = BuildGameState.new(game).call
    player = game_state.current_player
    board = game_state.board

    from = params[:step][:from].to_i
    to = params[:step][:to].to_i

    move_maker = MakeMove.new(game, player, board, from, to)
    move_maker.call

    flash.alert = move_maker.errors

    redirect_to game_path(game)
  end
end

class StepsController < ApplicationController
  def new
    @step = Step.new
  end

  def create
    game = Game.find(params[:game_id])
    game_state = BuildGameState.new(game).call
    player = game_state.current_player
    board = game_state.board

    if board.square_occupant(params[:step][:from].to_i) == player.colour
      Step.transaction do
        player.steps.create!(kind: step_kind(board), from: params[:step][:from].to_i, to: params[:step][:to].to_i)
      end
    end

    redirect_to game_path(game)
  end

  private

  def step_kind(board)
    if board.square_connections(params[:step][:from].to_i).include? params[:step][:to].to_i
      :simple
    else
      :jump
    end
  end
end

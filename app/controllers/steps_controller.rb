class StepsController < ApplicationController
  def create
    game = Game.find(params[:game_id])
    game_state = BuildGameState.new(game).call
    player = game_state.current_player
    board = game_state.board

    from = params[:step][:from].to_i
    to = params[:step][:to].to_i

    Step.transaction do
      step = player.steps.new(kind: step_kind(board, from, to), from: from, to: to)

      service = AvailableDestinations.new(board, player, from)
      available_destinations = service.call

      if available_destinations.include? to
        step.save!
      end

      flash.alert = service.errors if service.errors.present?
    end

    redirect_to game_path(game)
  end

  private

  def step_kind(board, from, to)
    if board.square_connections(from).include? to
      :simple
    else
      :jump
    end
  end
end

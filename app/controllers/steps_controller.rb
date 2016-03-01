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

      if mid_jump_path?(game, player)
        if (available_destinations.include? to) && (board.square_jump_connections(from).include? to)
          step.save!
        else
          flash.alert = ["That's not a valid move!"]
        end
      elsif available_destinations.include? to
        step.save!
      else
        flash.alert = ["That's not a valid move!"]
      end

      flash.alert = service.errors if service.errors.present?
    end

    redirect_to game_path(game)
  end

  private

  def step_kind(board, from, to)
    if board.square_simple_connections(from).include? to
      :simple
    else
      :jump
    end
  end

  def mid_jump_path?(game, player)
    game.steps.any? && (game.steps.last.player == player) && (player.steps.ordered.last.jump?)
  end
end

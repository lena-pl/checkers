class StepsController < ApplicationController
  def create
    game = Game.find(params[:game_id])
    game_state = BuildGameState.new(game).call
    player = game_state.current_player
    board = game_state.board

    from = params[:step][:from].to_i
    to = params[:step][:to].to_i

    if board.square_occupant(from).colour == player.colour
      Step.transaction do
        step = player.steps.new(kind: step_kind(board, from, to), from: from, to: to)

        validator = ValidateStep.new(board, step)

        if validator.call
          step.save!
        end

        flash.alert = validator.errors if validator.errors.present?
      end
    else
      flash.alert = ["That square doesn't hold one of your pieces!"]
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

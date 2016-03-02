class MakeMove
  attr_reader :game, :player, :board, :from, :to, :errors

  def initialize(game, player, board, from, to)
    @game = game
    @player = player
    @board = board
    @from = from
    @to = to
    @errors = []
  end

  def call
    available_destinations_service = AvailableDestinations.new(board, player, from)

    Step.transaction do
      step = player.steps.new(kind: step_kind(board, from, to), from: from, to: to)

      available_destinations = available_destinations_service.call

      if !piece_belongs_to_player?
        @errors = ["That square doesn't hold one of your pieces!"]
      elsif mid_jump_path?
        if (available_destinations.include? to) && (board.square_jump_connections(from).include? to)
          step.save!
        else
          @errors = ["That's not a valid move!"]
        end
      elsif available_destinations.include? to
        step.save!
      else
        @errors = ["That's not a valid move!"]
      end
    end

    @errors = available_destinations_service.errors if available_destinations_service.errors.present?

    @errors.empty?
  end

  private

  def step_kind(board, from, to)
    if board.square_simple_connections(from).include? to
      :simple
    else
      :jump
    end
  end

  def mid_jump_path?
    game.steps.any? && (game.steps.last.player == player) && (player.steps.ordered.last.jump?)
  end

  def piece_belongs_to_player?
    board.square_occupant(from) && (board.square_occupant(from).colour == player.colour)
  end
end

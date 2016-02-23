class TakeTurn
  attr_reader :errors, :game_state

  def initialize(game_state:, player:, steps:)
    @game_state = game_state
    @steps = steps
    @player = player
    @board = game_state.board
    @errors = []
  end

  def call
    if player_allowed_to_move?
      @board = apply_steps

      @errors.push "You must make all available jumps to complete your turn" if @steps.last.kind == "jump" && more_pieces_can_be_captured?

      find_next_player if @errors.empty?
    else
      @errors.push "It's not your turn right now!"
    end

    @errors.uniq
    @game_state.board = @board

    @game_state
  end

  private

  def player_allowed_to_move?
    @game_state.current_player == @player
  end

  def apply_steps
    @steps.inject(@board) do |current_board, step|
      service = ApplyStep.new(current_board, step)
      service.call

      @errors += service.errors
      service.board
    end
  end

  def find_next_player
    @game_state.current_player = @game_state.game.players.find { |player| player != @player }
  end

  def more_pieces_can_be_captured?
    current_destination = @steps.last.to

    AvailableTurns.new(player: @player, board: @board, piece_position: current_destination).more_jump_moves_available?
  end
end

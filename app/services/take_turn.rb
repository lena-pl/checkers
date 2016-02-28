class TakeTurn
  attr_reader :game_state, :steps, :board, :player, :errors

  def initialize(game_state:, player:, steps:)
    @game_state = game_state
    @steps = steps
    @player = player
    @board = game_state.board
    @errors = []
  end

  def call
    if player_allowed_to_move? && steps.any?
      board = apply_steps

      errors.push "You still have more jumps available! Complete the path to end your turn." if steps.last.jump? && more_pieces_can_be_captured? && !piece_reached_kings_row?

      board.crown_piece(steps.last.to) if piece_reached_kings_row?

      find_next_player if errors.empty?
    else
      errors.push "It's not your turn right now!"
    end

    errors.uniq!
    game_state.board = board

    game_state
  end

  private

  def player_allowed_to_move?
    game_state.current_player == player
  end

  def apply_steps
    steps.inject(board) do |current_board, step|
      service = ApplyStep.new(current_board, step)
      service.call

      service.board
    end
  end

  def find_next_player
    game_state.current_player = game_state.game.players.find { |player| player != @player }
  end

  def more_pieces_can_be_captured?
    position = steps.last.to
    potential_destinations = AvailableDestinations.new(board, player, position).call

    jump_destinations = potential_destinations - (board.square_simple_connections(position) & potential_destinations)

    jump_destinations.any?
  end

  def piece_reached_kings_row?
    board.kings_row(player).include? steps.last.to
  end
end

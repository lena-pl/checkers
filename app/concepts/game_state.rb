class GameState
  attr_reader :game, :player_one, :player_two
  attr_accessor :current_player, :board

  def initialize(game, board, current_player)
    @game = game
    @player_one = game.players.first
    @player_two = game.players.second
    @board = board
    @current_player = current_player
  end

  def over?
    winner_found? || draw?
  end

  def winner
    if winner_found?
      game.players.find { |player| player != loser }
    end
  end

  def loser
    if winner_found?
      player_lost?(player_one) ? player_one : player_two
    end
  end

  def draw?
    !legal_moves_left_for_player?(player_one) && !legal_moves_left_for_player?(player_two)
  end

  private

  def winner_found?
    player_lost?(player_one) || player_lost?(player_two)
  end

  def player_lost?(player)
    (!active_pieces_left_for_player?(player) || !legal_moves_left_for_player?(player)) && !draw?
  end

  def active_pieces_left_for_player?(player)
    active_pieces_count(player) > 0
  end

  def active_pieces_count(player)
    board.player_pieces(player).count
  end

  def legal_moves_left_for_player?(player)
    board.player_pieces(player).map do |piece|
      AvailableDestinations.new(board, player, piece.position).call
    end.flatten.any?
  end
end

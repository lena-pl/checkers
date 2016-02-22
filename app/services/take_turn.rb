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
    enemies = adjacent_enemies(forward_facing_adjacent_node_positions(current_destination))

    if enemies.present?
      empty_destinations(enemies_with_directions(enemies, forward_facing_adjacent_node_positions(current_destination))).present?
    else
      false
    end
  end

  def forward_facing_adjacent_node_positions(square_position)
    case @player.colour
    when "red"
      @board.square_connections(square_position).select { |connection| connection > square_position }
    when "white"
      @board.square_connections(square_position).select { |connection| connection < square_position }
    else
      raise ArgumentError
    end
  end

  def adjacent_enemies(positions)
    positions.select { |position| @board.square_occupant(position) == enemy_colour }
  end

  def enemies_with_directions(enemies, forward_facing_node_positions)
    positions = forward_facing_node_positions.sort

    enemies.map do |enemy|
      if enemy == positions.first
        [enemy, "left"]
      else
        [enemy, "right"]
      end
    end
  end

  def empty_destinations(enemies_and_their_directions)
    potential_destinations = enemies_and_their_directions.map do |enemy_direction_pair|
      enemy = enemy_direction_pair[0]
      direction = enemy_direction_pair[1]
      positions = forward_facing_adjacent_node_positions(enemy)

      in_horizontal_direction(direction, positions)
    end

    potential_destinations.reject! { |destination| destination == nil }

    if potential_destinations.present?
      potential_destinations.select { |position| @board.square_occupant(position) == "empty" }
    else
      []
    end
  end

  def in_horizontal_direction(direction, positions)
    positions.sort

    if direction == "right"
      positions.last
    else
      positions.first
    end
  end

  def enemy_colour
    case @player.colour
    when "red"
      "white"
    when "white"
      "red"
    else
      raise ArgumentError
    end
  end
end

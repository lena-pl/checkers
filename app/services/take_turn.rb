class TakeTurn
  attr_reader :errors, :game_state

  def initialize(game_state:, player_colour:, steps:)
    @game_state = game_state
    @steps = steps
    @player = game_state.game.players.find { |player| player.colour == player_colour }
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
    puts "***********************************"
    puts "TAKE TURN COMPLETE"

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

      @errors + service.errors
      service.board
    end
  end

  def find_next_player
    @game_state.current_player = @game_state.game.players.find { |player| player != @player }
  end

  def more_pieces_can_be_captured?
    current_destination = @board.square_by_position(@steps.last.to)
    enemies = adjacent_enemies(forward_facing_adjacent_nodes(current_destination))

    if enemies.present?
      empty_destinations(enemies_with_directions(enemies, forward_facing_adjacent_nodes(current_destination))).present?
    else
      false
    end
  end

  def forward_facing_adjacent_nodes(square)
    nodes = []

    case @player.colour
    when "red"
      positions = square.connections.select { |connection| connection > square.position }
      nodes = positions.map { |position| @board.square_by_position(position) }
    when "white"
      positions = square.connections.select { |connection| connection < square.position }
      nodes = positions.map { |position| @board.square_by_position(position) }
    else
      raise ArgumentError
    end

    nodes
  end

  def adjacent_enemies(squares)
    squares.select { |square| square.occupant == enemy_colour }
  end

  def enemies_with_directions(enemies, forward_facing_nodes)
    positions = forward_facing_nodes.map { |node| node.position }.sort

    enemies.map do |enemy|
      if enemy.position == positions.first
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
      nodes = forward_facing_adjacent_nodes(enemy)

      in_horizontal_direction(direction, nodes)
    end

    potential_destinations.select { |square| square.occupant == "empty" }
  end

  def in_horizontal_direction(direction, nodes)
    positions = nodes.map {|node| node.position}.sort

    if direction == "right"
      @board.square_by_position(positions.last)
    else
      @board.square_by_position(positions.first)
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

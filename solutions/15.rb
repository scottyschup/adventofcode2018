require 'colorize'

class CaveCombat
  attr_reader :board, :movable_pieces

  def initialize(input_file: 'inputs/15.txt')
    @board = Board.new(input_file)
    @movable_pieces = @board.movable_pieces
    @rounds = 0
  end

  def run
    until game_over?
      move_pieces
      attack
      @rounds += 1
    end
    puts final_score
  end

  def move_pieces

  end

  def attack

  end

  def final_score
    hit_points = @movable_pieces.inject(0) do |sum, piece|
      sum + piece.hit_points
    end
    @rounds * hit_points
  end

  def game_over?
    @movable_pieces.map { |piece| piece.class }.uniq.length == 1
  end

  def print_board
    @board.print_grid
  end
end

class Board
  class InvalidSpaceError < StandardError; end

  SYMBOLS = {
    '#' => :wall,
    '.' => :empty,
    ' ' => :empty,
    'G' => :goblin,
    'E' => :elf
  }

  attr_accessor :movable_pieces, :grid

  def initialize(input_file)
    @input = File.open(input_file).readlines
    @movable_pieces = []
    setup_grid!
  end

  def to_s
    inspect
  end

  def inspect
    "rows: #{@max_y + 1}, cols: #{@max_x + 1}"
  end

  def setup_grid!
    @grid = []
    @input.map!(&:strip)
    @max_y = @input.length - 1
    @max_x = @input.first.length - 1

    @input.each_with_index do |row, y|
      next if row.length.zero?
      @grid[y] = []
      row.split('').each_with_index do |cell, x|
        pos = [x, y]
        case cell
        when '#'
          @grid[y][x] = Wall.new(pos: pos)
        when '.', ' '
          @grid[y][x] = Space.new(pos: pos)
        when 'G'
          g = place_piece!(Goblin.new(pos: pos, board: self), pos)
          @movable_pieces << g
        when 'E'
          e = place_piece!(Elf.new(pos: pos, board: self), pos)
          @movable_pieces << e
        end
      end
    end
    nil
  end

  def out_of_bounds?(pos)
    return true if pos.any? { |n| n < 0 }
    pos[0] > @max_x || pos[1] > @max_y
  end

  def empty?(pos)
    return false if out_of_bounds?(pos)
    x, y = pos
    cell = @grid[y][x]
    SYMBOLS[cell] == :empty
  end

  def available?(pos)
    !empty?(pos) && !out_of_bounds?(pos)
  end

  def peek(pos)
    raise InvalidSpaceError.new(piece) if out_of_bounds?(pos)
    x, y = pos
    @grid[y][x]
  end

  def place_piece!(piece, new_pos)
    raise InvalidSpaceError.new(new_pos) unless available?(new_pos)
    x, y = new_pos
    piece.pos = new_pos
    @grid[y][x] = piece
  end

  def remove_piece!(piece)
    raise InvalidSpaceError.new(piece.pos) unless available?(piece.pos)
    x, y = piece.pos
    @grid[y][x] = Space.new(pos: pos)
    piece
  end

  def spaces_adjacent_to(pos)
    raise InvalidSpaceError.new(pos) unless available?(pos)
    MovablePiece::DELTAS.values
      .map { |delta| MovablePiece.apply_delta(pos, delta) }
      .select{ |pos_to_check| available?(pos_to_check) }
  end

  def move_piece(piece, new_pos)
    raise InvalidSpaceError.new(new_pos) unless available?(new_pos)
    remove_piece!(piece)
    place_piece!(piece, new_pos)
  end

  def print_grid
    @grid.each do |row|
      puts row.map { |cell| cell.pretty_symbol }.join(' ')
    end
    nil
  end
end

class GamePiece
  attr_accessor :pos
  attr_reader :symbol

  def initialize(pos:, **kwargs)
    @pos = pos
  end

  def pretty_symbol
    @symbol.colorize(@color)
  end
end

class MovablePiece < GamePiece
  DELTAS = {
    up: [0, -1],
    left: [-1, 0],
    right: [1, 0],
    down: [0, 1]
  }

  def self.apply_delta(pos, delta)
    [pos[0] + delta[0], pos[1] + delta[1]]
  end

  attr_accessor :hit_points
  attr_reader :attack_power, :board

  def initialize(pos:, **kwargs)
    @hit_points = 200
    @attack_power = 3
    @board = kwargs[:board]
    @enemies = []
    super
  end

  def available_adjacent_spaces
    DELTAS.values
      .map { |delta| self.class.apply_delta(pos, delta) }
      .select{ |pos_to_check| @board.available?(pos_to_check) }
  end

  def move
    identify_enemies
    identify_target_spaces
    identify_reachable_spaces
    choose_optimal_target
    choose_optimal_path
    take_step
  end

  def simple_move
    identify_enemies
    ripple
    pick_optimal_path
  end

  def identify_enemies
    @enemies = @board.movable_pieces.select do |person|
      enemy != person.enemy
    end
  end

  def ripple
    identify_enemies if @enemies.empty?
    puts @enemies
    @seen = {}
    @queue = Hash.new { |h, k| h[k] = [] }
    @nearest = []
    @num_steps = 1

    @enemies.each do |enemy|
      @queue[@num_steps] += enemy.available_adjacent_spaces
    end

    while @nearest.empty?
      @queue[@num_steps].each do |space|
        @seen[space] ||= @num_steps
        @nearest << [space, @num_steps] if space == pos
        @board.spaces_adjacent_to(space).each do |s|
          @queue[@num_steps + 1] << s unless @seen[s]
        end
      end
      @num_steps += 1
      puts "Round: #{@num_steps}"
      puts @seen.length
      puts @queue[@num_steps].length
    end
    @nearest
  end

  def pick_optimal_path

  end

  def identify_target_spaces
    @adjacent_spaces = []
    @enemies.each do |enemy|
      @adjacent_spaces << enemy.available_adjacent_spaces
    end
  end

  def identify_reachable_spaces
    @queue = []
    @seen = {}
    @adjacent_spaces.each do |space|
      # TODO
    end
  end
end

class Goblin < MovablePiece
  def initialize(pos:, color: :green, **kwargs)
    @color = color
    @symbol = 'G'
    super
  end

  def enemy
    Elf
  end
end

class Elf < MovablePiece
  def initialize(pos:, color: :yellow, **kwargs)
    @color = color
    @symbol = 'E'
    super
  end

  def enemy
    Goblin
  end
end

class Wall < GamePiece
  def initialize(pos:, color: :light_black)
    @color = color
    @symbol = '#'
    super
  end
end

class Space < GamePiece
  def initialize(pos:, color: :black)
    @color = color
    @symbol = '.'
    super
  end
end

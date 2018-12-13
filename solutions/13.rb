PATHS ||= {
  :'-' => { left: true, right: true },
  :'|' => { up: true, down: true },
  :'/' => {
    left: { up: true, left: true },
    right: { down: true, right: true },
    up: { up: true, left: true },
    down: { down: true, right: true }
  },
  :'\\' => {
    left: { down: true, left: true },
    right: { up: true, right: true },
    up: { up: true, right: true },
    down: { down: true, left: true }
  },
  :'+' => { up: true, down: true, left: true, right: true }
}
CARTS ||= {
  :'<' => { dir: :left, left: true, right: true },
  :'>' => { dir: :right, left: true, right: true  },
  :'^' => { dir: :up, up: true, down: true },
  :'v' => { dir: :down, up: true, down: true }
}

DIRS ||= {
  left: [-1, 0],
  up: [0, -1],
  right: [1, 0],
  down: [0, 1]
}

OPP_DIRS ||= {
  left: :right,
  right: :left,
  up: :down,
  down: :up
}

class Cell
  attr_accessor :x, :y
  def initialize(x:, y:, up: false, right: false, down: false, left: false, **kwargs)
    @x = x
    @y = y
    @up = up
    @right = right
    @down = down
    @left = left
  end

  def to_s
    "x: #{x}, y: #{y}, dirs: #{available_directions}"
  end

  def available_directions
    DIRS.keys.inject([]) { |agg, key| agg << key if can_go?(key); agg }
  end

  def can_go?(dir)
    instance_variable_get("@#{dir}")
  end

  def intersection?
    @up && @down && @left && @right
  end

  def empty_cell?
    @up || @down || @left || @right
  end
end

class Cart
  attr_accessor :curr_cell, :dir

  def initialize(curr_cell:, dir:, **kwargs)
    @curr_cell = curr_cell
    @dir = dir
    @dir_delta = -1
  end

  def to_s
    "Current cell: #{curr_cell}, dir: #{dir}"
  end

  def curr_dir
    if @curr_cell.intersection?
      idx = DIRS.keys.index(@dir)
      new_idx = (idx + @dir_delta) % 4
      increment_delta!
      @dir = DIRS.keys[new_idx]
    elsif @curr_cell.can_go?(@dir)
      @dir
    else
      @dir = (@curr_cell.available_directions - [OPP_DIRS[@dir]])[0]
    end
  end

  def increment_delta!
    @dir_delta = case @dir_delta
    when -1
      0
    when 0
      1
    when 1
      -1
    end
  end
end

class Board
  attr_accessor :cells, :carts

  def initialize
    @cells = []
    @carts = []
  end

  def has_cell?(x, y)
    @cells[y] && @cells[y][x]
  end

  def cell_at(x, y)
    @cells[y][x]
  end

  def add_cell(char, y, x)
    puts("x: #{x}, y: #{y}, char: #{char}") if verbose?

    if PATHS.keys.include?(char)
      args = [:'/', :'\\'].include?(char) ? handle_curve(PATHS[char], x, y) : PATHS[char]
    elsif CARTS.keys.include?(char)
      args = CARTS[char]
    else
      args = {}
    end

    curr_cell = Cell.new(x: x, y: y, **args)

    @cells[y] ||= []
    @cells[y][x] = curr_cell
    @carts << Cart.new(curr_cell: curr_cell, **args) if args[:dir]
  end

  def handle_curve(opts, x, y)
    if has_cell?(x - 1, y)
      return cell_at(x - 1, y).can_go?(:right) ? opts[:left] : opts[:right]
    elsif has_cell?(x, y - 1)
      return cell_at(x, y - 1).can_go?(:down) ? opts[:up] : opts[:down]
    end
    opts[:right]
  end

  def sort_carts!
    # sort by cols, then by rows, so top left is first
    @carts.sort! { |x, y| x.curr_cell.x <=> y.curr_cell.x }.sort! { |x, y| x.curr_cell.y <=> y.curr_cell.y }
  end
end

class Game
  attr_accessor :board

  def initialize(last_cart: true, verbose: false)
    @game_over = false
    @crash = nil
    @verbose = verbose
    @last_cart = last_cart
    @board = Board.new
    fill_board!
  end

  def fill_board!
    rows = File.open('inputs/13.txt').readlines
    rows.each_with_index do |row, y|
      process_row(row, y)
    end
  end

  def process_row(row, y)
    cells = row.split('').map(&:strip).map(&:to_sym)
    cells.each_with_index do |cell, x|
      @board.add_cell(cell, y, x)
    end
  end

  def collisions
    collided_carts = []
    (1...@board.carts.length).each do |n|
      this_cart = @board.carts[n]
      prev_cart = @board.carts[n - 1]
      if (prev_cart.curr_cell == this_cart.curr_cell)
        collided_carts += [this_cart, prev_cart]
      end
    end
    collided_carts
  end

  def collision?
    !collisions.empty?
  end

  def verbose?
    @verbose
  end

  def run(verbose: false)
    @verbose = verbose
    i = 1
    until game_over?
      puts("Tick ##{i}") if verbose?
      @board.sort_carts!
      step_forward
      i += 1
    end
    @output
  end

  def game_over?
    if !@last_cart && @crash
      @output = @crash
      return true
    end
    if @board.carts.length == 1
      cell = @board.carts[0].curr_cell
      @output = "#{cell.x},#{cell.y}"
      return true
    end
    false
  end

  def step_forward
    removals = []
    puts("Carts (n = #{@board.carts.length})") if verbose?
    @board.carts.each do |cart|
      puts("\t#{cart}") if verbose?
      ∆_x, ∆_y = DIRS[cart.curr_dir]
      new_x = cart.curr_cell.x + ∆_x
      new_y = cart.curr_cell.y + ∆_y
      cell = @board.cell_at(new_x, new_y)
      cart.curr_cell = cell
      if collision?
        @crash = "#{cell.x},#{cell.y}"
        removals += collisions
      end
    end
    unless removals.empty?
      puts("Collisions:") if verbose?
      removals.each do |cart|
        puts("\t#{cart}") if verbose?
        @board.carts.delete(cart)
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  g = Game.new last_cart: false
  puts "Part 1: #{g.run}"

  g2 = Game.new
  puts "Part 2: #{g2.run}"
end

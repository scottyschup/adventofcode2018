class ElfConstruction
  DELTAS ||= {
    N: [0, -1],
    S: [0, 1],
    W: [-1, 0],
    E: [1, 0]
  }
  V_DOOR ||= '|'
  H_DOOR ||= '-'
  WALL ||= '#'

  def initialize(file: nil, display: false)
    @file = file || 'inputs/20.txt'
    @display = display
    @round = 0
    @queue = []
    @starts = [[0, 0]]
    setup_grid!
    process_input!
  end

  def setup_grid!
    #    |-1 | 0 | 1
    # ---+-----------
    # -1 | # | ? | #
    #  0 | ? | X | ?
    #  1 | # | ? | #
    @grid = {
      [-1, -1] => '#',
      [0, -1] => '?',
      [1, -1] => '#',
      [-1, 0] => '?',
      [0, 0] => 'x',
      [1, 0] => '?',
      [-1, 1] => '#',
      [0, 1] => '?',
      [1, 1] => '#'
    }
  end

  def process_input!
    input = File.open(@file).readline.chomp # Only one line

  end

  def print_grid
    min_x, min_y = @grid.sort
    max_x, max_y = @grid.sort
    x_range = 0..(max_x - min_x)
    y_range = 0..(max_y - min_y)
    puts "Round #{@round}"
    puts "min: #{[min_x, min_y]}, max: #{[max_x, max_y]}"
    y_range.each do |y|
      printf(y.to_s.rjust(3, ' '))
      x_range.each do |x|
        pos = [x, y]
        printf @grid[pos]
      end
      puts
    end
  end

  def move(dir)
    @curr_pos
  end

  def last_start
    @starts.pop
  end

  def run

  end
end

class Instruction
  def initialize(input:, pos:)
    @pos = pos
    @input = input
  end
end

if __FILE__ == $0
  ElfConstruction.new(display: ENV['DISPLAY']).run
end

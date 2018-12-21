class ElfConstruction
  DELTAS = {
    N: [0, -1],
    S: [0, 1],
    W: [-1, 0],
    E: [1, 0]
  }

  def initialize(file:)
    @file = file
    @round = 0
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
    input = File.open(@file).readline.chomp

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

      end
    end
  end

  def run

  end
end

class Instruction
  def initialize(input:, pos:)
    @pos
    @input = input
  end

  def method_name

  end
end

if __FILE__ == $0
  ec = ElfConstruction.new
  ec.run
end

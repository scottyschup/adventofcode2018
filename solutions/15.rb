class Board
  SYMBOLS = {
    '#' => :wall,
    '.' => :empty,
    'G' => :goblin,
    'E' => :elf
  }
  def initialize(input_file)
    @input = File.open(input_file).readlines
  end

  def setup
    @input.each do |line|

    end
  end
end

class Game
  def initialize(input_file)
    @board = Board.new(input_file)

  end
end

class Person

end

class Goblin < Person

end

class Elf < Person

end

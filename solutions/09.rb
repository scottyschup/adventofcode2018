class Circle
  attr_accessor :current
  attr_reader :root, :length

  def initialize(root: nil)
    self.root = root
    @current = root
    @length = root ? 1 : 0
  end

  def root=(point)
    @root = point
    @current ||= point
    return unless root
    root.nxt = root
    root.prv = root
  end

  def insert_after(new_point, target = nil)
    @length += 1
    return self.root = new_point unless root
    target ||= root.prv
    before = target
    after = target.nxt
    link(before, new_point, after)
  end

  def link(a, b, c)
    a.nxt = b
    b.nxt = c
    b.prv = a
    c.prv = b
  end

  def remove!(point)
    @length -= 1
    point.prv.nxt = point.nxt
    point.nxt.prv = point.prv
    @root = point.nxt if point == @root
    @current = point.nxt if point == @current
    point.val
  end

  def remove_current!
    remove!(@current)
  end

  def print_values
    this = @root
    terminus = @root.prv
    until this == terminus
      printf "[" if this == current
      printf "#{this.val}"
      printf "]" if this == current
      printf ' '
      this = this.nxt
    end
    puts
  end
end

class Point
  attr_accessor :prv, :nxt, :val

  def initialize(val, prv: nil, nxt: nil)
    @val = val
    @prv = prv
    @nxt = nxt
  end
end

class FasterMarbleGame
  MULTIPLIER = 23

  def initialize(num_players:, last_marble:, verbose: false)
    @num_players = num_players
    @last_marble = last_marble
    @circle = Circle.new(root: Point.new(0))
    @marble_count = 1
    @current_player = 0
    @scores = Array.new(num_players, 0)
    @verbose = verbose
  end

  def current_marble
    @circle.current
  end

  def current_marble=(point)
    @circle.current = point
  end

  def add_marble!
    if @marble_count % MULTIPLIER == 0
      @scores[@current_player] += @marble_count
      7.times { @circle.current = @circle.current.prv }
      @scores[@current_player] += @circle.remove_current!
    else
      new_marble = Point.new(@marble_count)
      @circle.insert_after(new_marble, current_marble.nxt)
      self.current_marble = new_marble
    end
  end

  def verbose?
    !!@verbose
  end

  def print_circle
    return if @circle.length > 100
    printf "player #{@current_player + 1}: "
    @circle.print_values
  end

  def print_progress
    percent = @last_marble / 100
    progress, mod = @marble_count.divmod(percent.zero? ? 1 : percent)
    progress = [progress, 100].min
    return unless mod.zero?
    system 'clear'
    puts "Progress: #{'*' * progress}#{' ' * (100 - progress)}| #{progress}%"
    puts(Time.now - @start_time)
  end

  def run
    @start_time = Time.now
    until @marble_count > @last_marble
      add_marble!
      verbose? ? print_circle : print_progress
      @marble_count += 1
      @current_player = (@current_player + 1) % @num_players
    end
    max = @scores.max
    player = @scores.index(max) + 1
    puts "Player #{player} has #{max} points"
  end

end

# class MarbleGame
#   MULTIPLIER = 23
#
#   def initialize(num_players:, last_marble:, verbose: false)
#     @num_players = num_players
#     @last_marble = last_marble
#     @circle = [0]
#     @marble_count = 1
#     @current_marble_idx = 0
#     @current_player = 0
#     @scores = Array.new(num_players, 0)
#     @verbose = verbose
#   end
#
#   def add_marble!
#     if @marble_count % MULTIPLIER == 0
#       @scores[@current_player] += @marble_count
#       delete_idx = (@current_marble_idx - 7) % @circle.length
#       @scores[@current_player] += @circle.delete_at(delete_idx)
#       @current_marble_idx = delete_idx
#     elsif @circle.length < 2
#       @circle << @marble_count
#       @current_marble_idx = @circle.length - 1
#     else
#       insert_idx = (@current_marble_idx + 2) % @circle.length
#       insert_idx = @circle.length if insert_idx.zero?
#       @circle.insert(insert_idx, @marble_count)
#       @current_marble_idx = insert_idx
#     end
#   end
#
#   def verbose?
#     !!@verbose
#   end
#
#   def print_circle
#     printf "player #{@current_player + 1}: "
#     @circle.each_with_index do |n, idx|
#       if idx == @current_marble_idx
#         printf("[#{n}] ")
#       else
#         printf("#{n} ")
#       end
#     end
#     puts
#   end
#
#   def print_progress
#     percent = @last_marble / 100
#     progress, mod = @marble_count.divmod(percent)
#     return unless mod.zero?
#     system 'clear'
#     puts "Progress: #{'*' * progress}#{' ' * (100 - progress)}| #{progress}%"
#     puts(Time.now - @start_time)
#   end
#
#   def run
#     @start_time = Time.now
#     print_circle if verbose?
#     until @marble_count > @last_marble
#       add_marble!
#       verbose? ? print_circle : print_progress
#       @marble_count += 1
#       @current_player = (@current_player + 1) % @num_players
#     end
#     max = @scores.max
#     player = @scores.index(max) + 1
#     puts "Player #{player} has #{max} points"
#   end
# end

if __FILE__ == $PROGRAM_NAME
  num_players = ENV['NUM_PLAYERS'].to_i
  last_marble = ENV['LAST_MARBLE'].to_i
  verbose = ENV['VERBOSE'] == 'true'
  FasterMarbleGame.new(
    num_players: num_players,
    last_marble: last_marble,
    verbose: verbose
  ).run
end

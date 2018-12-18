class WaterfallHell
  DELTA = {
    up: [0, -1],
    down: [0, 1],
    left: [-1, 0],
    right: [1, 0]
  }

  def initialize(file: nil, display: false, start: 0, stop: nil, follow: 0)
    @file = file || 'inputs/17.txt'
    @display = display
    @follow = follow
    @start = start
    @stop = stop || Float::INFINITY
    @x_min = Float::INFINITY
    @y_min = 0
    @x_max = 0
    @y_max = 0
    @max_y_seen = 0
    @grid = {}
    @queue = []
    @curr_pos = [nil, nil]
    fill_grid!
  end

  def print_grid(center: nil, width: 100, height: 15)
    system 'clear'
    @center = center
    @center ||= @curr_pos unless @curr_pos.any? { |el| el.nil? }
    @center ||= @queue.first
    center_x, center_y = @center
    x_range ||= (center_x - width / 2)..(center_x + width / 2)
    y_range ||= (center_y - height / 2)..(center_y + height / 2)
    y_offset = y_range.first < 0 ? -y_range.first : 0
    y_range = (y_range.first + y_offset)..(y_range.last + y_offset)

    y_range.each do |y|
      x_range.each do |x|
        pos = [x, y]
        queued = @queue.include?(pos) ? 'V' : nil
        # queued = nil

        if char = @grid[pos]
          printf(queued || char)
        else
          printf('.')
        end
      end
      puts
    end
  end

  def print_round_summary
    print_grid if display?
    puts("*" * 44)
    puts "Round #{@round} Summary"
    puts "#{min_max}"
    puts "\tMax y seen: #{@max_y_seen}"
    puts "\tGrid center: #{@center}"
    puts "\tClay: #{@grid.values.count { |el| el == '#' }}"
    puts "\tWater: #{@grid.values.count { |el| el == '|' || el == '~' }}"
    puts "\tQueue: #{@queue.length}"

    @queue.each_with_index do |pos, i|
      pos = pos.nil? ? 'nil' : pos
      i % 10 == 0 ? printf("\t\t") : nil
      i % 10 != 9 ? printf("#{pos} ") : puts(pos.to_s)
    end
    puts
    puts("*" * 44)
    puts
    sleep 0.03 if display?
  end

  def run
    @round = 1
    until @queue.empty?
      puts "#{'*' * 10} Round #{@round} #{'*' * 10}"
      puts "Queue: #{@queue}"
      success = process_queue!
      print_round_summary if success
      @round += 1
    end
    # print_final_summary
  end

  def process_queue!
    @curr_pos = @queue.shift
    @max_y_seen = @curr_pos[1] if @curr_pos[1] > @max_y_seen
    puts "--> Current position: #{@curr_pos}" if display?
    if out_of_bounds?(@curr_pos)
      puts "\tOut of bounds: #{@curr_pos}"
      return nil
    elsif still?(@curr_pos)
      puts "\tAlready flipped: #{@curr_pos}"
      return nil
    end
    next_move
  end

  def next_move
    %i(down left right).each do |dir|
      next_pos = move(dir, @curr_pos)
      puts "Checking #{dir}ward move: #{next_pos}" if display?
      next if out_of_bounds?(next_pos)

      @curr_dir = dir
      @curr_state = '|'

      case @grid[next_pos]
      when nil
        @queue << next_pos
        break if moving_down?
      when '|'
        break if moving_down?
      when '~'
        next if moving_down?
      when '#'
        @curr_state = '~'
        flip_row!(next_pos)
        break if moving_down?
      end

    end
    update_grid_with_current_state!
    true
  end

  def update_grid_with_current_state!
    @grid[@curr_pos] = @curr_state
  end

  # Rows
  def flip_row!(pos = nil)
    pos ||= @curr_pos
    puts "\tFlip row around point: #{pos}"

    return false unless is_contained?(walls_range(pos))
    fill_row!(pos)
  end

  def fill_row!(pos = nil)
    pos ||= @curr_pos
    puts "Fill row at #{pos}"
    above = move(:up, pos)
    @queue << above
    row_from_range[1...-1].each { |cell| @grid[cell] = @curr_state }
  end

  def row_from_range(range = nil, y = nil)
    range ||= walls_range
    return nil if range.nil?
    y ||= @curr_pos[1]
    range.map { |x| [x, y] }
  end

  def is_contained?(x_range = nil, y = nil)
    x_range ||= walls_range
    puts "\tis_contained? x range: #{x_range}, y: #{y}" if display?
    if x_range.nil?
      puts "\t\tInvalid range: #{x_range.nil? ? 'nil' : x_range}" if display?
      return false
    end
    y ||= @curr_pos[1]

    x_arr = x_range.to_a
    floor_y = y + 1
    has_floor = x_arr[1...-1].all? do |x|
      pos = [x, floor_y]
      clay?(pos) || still?(pos)
    end
    puts "\t\tHas floor: #{has_floor ? 'yes' : 'no'}"
    has_floor
  end

  def walls_range(pos = nil)
    pos ||= @curr_pos
    puts "\tGetting walls range from pos: #{pos}"
    curr_walls = nearest_walls(*pos)
    if curr_walls.any? { |el| el.nil? } || curr_walls.length != 2
      puts "\t\tCouldn't get one or both walls: #{curr_walls}"
      return nil
    end
    r = Range.new(*curr_walls)
    puts "\tSuccess: #{r}"
    r
  end

  # Returns an array of the left and right wall's x-axis value
  def nearest_walls(x = nil, y = nil)
    puts "\tNearest walls to #{x}, #{y}"
    x ||= @curr_pos[0]
    y ||= @curr_pos[1]
    walls = Array.new(2, nil)

    %i(left right).each do |dir|
      printf "\t\tChecking #{dir} side: "
      this = @curr_pos.dup
      idx = dir == :left ? 0 : 1
      until clay?(this) || out_of_bounds?(this)
        this = move(dir, this)
      end
      # Leave wall nil if OOB
      puts "#{this}"
      walls[idx] = this[0] unless out_of_bounds?(this)
    end
    walls
  end

  # Movement
  def move(dir, pos)
    ∆x, ∆y = DELTA[dir]
    [pos[0] + ∆x, pos[1] + ∆y]
  end

  def moving_up?
    @curr_dir == :up
  end

  def moving_down?
    @curr_dir == :down
  end

  def moving_left?
    @curr_dir == :left
  end

  def moving_right?
    @curr_dir == :right
  end

  # Search
  def clay?(pos = nil)
    pos ||= @curr_pos
    @grid[pos] == '#'
  end

  def flow?(pos = nil)
    pos ||= @curr_pos
    @grid[pos] == '|'
  end

  def still?(pos = nil)
    pos ||= @curr_pos
    @grid[pos] == '|'
  end

  def empty?(pos = nil)
    pos ||= @curr_pos
    @grid[pos].nil?
  end

  def out_of_bounds?(pos = nil)
    pos ||= @curr_pos
    pos[0] < @x_min || pos[1] < @y_min ||
      pos[0] > @x_max || pos[1] > @y_max
  end

  def min_max
    { x_min: @x_min, x_max: @x_max, y_min: @y_min, y_max: @y_max }
  end

  private

  def display?
    @display
  end

  def extract_coords(line)
    coords = []
    line.split(', ').sort.each do |coord|
      coords << coord.split('=').last
    end
    coords.map! do |n_str|
      nums = n_str.split('..').map(&:to_i)
      nums.length > 1 ? Range.new(*nums).to_a : nums
    end
    coords
  end

  def fill_grid!
    File.open(@file).readlines.map(&:chomp).each do |line|
      process_line!(line)
    end
    start_pos = [500, 0]
    @grid[start_pos] = '+'
    @queue << start_pos
    @grid
  end

  def process_line!(line)
    x_coord, y_coord = extract_coords(line)
    update_min_max!(x_coord, y_coord)

    if x_coord.length > 1
      x_coord.each do |x|
        @grid[[x, y_coord.first]] = '#'
      end
    elsif y_coord.length > 1
      y_coord.each do |y|
        @grid[[x_coord.first, y]] = '#'
      end
    end
    true
  end

  def update_min_max!(x_arr, y_arr)
    @x_min = x_arr.min < @x_min ? x_arr.min : @x_min
    @y_min = y_arr.min < @y_min ? y_arr.min : @y_min
    @x_max = x_arr.max > @x_max ? x_arr.max : @x_max
    @y_max = y_arr.max > @y_max ? y_arr.max : @y_max
  end
end

def env(var_name, type = nil)
  var = ENV[var_name] || ENV[var_name.upcase] || ENV[var_name.downcase]
  case type
  when :integer
    var.nil? ? nil : var.to_i
  when :float
    var.nil? ? nil : var.to_f
  when :string
    var.nil? ? nil : var.to_s
  when :boolean
    ['true', 'True', 'TRUE', 1, '1'].include?(var)
  else
    var.nil? ? nil : var
  end
end

if __FILE__ == $PROGRAM_NAME
  kwargs = {}
  kwargs[:display] = env('display', :boolean)
  kwargs[:follow] = env('follow', :integer)
  kwargs[:start] = env('start', :integer)
  kwargs[:stop] = env('stop', :integer)
  kwargs[:file] = env('file', :string)

  wfh = WaterfallHell.new(**kwargs)
  wfh.print_grid(height: 25, width: 120)
  wfh.run
end

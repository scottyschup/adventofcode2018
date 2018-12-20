require 'colorize'

class WaterfallHell
  DELTA = {
    up: [0, -1],
    down: [0, 1],
    left: [-1, 0],
    right: [1, 0]
  }

  def initialize(file: nil, display: false, verbose: false, start: nil, stop: nil,
                 center: nil, fast: nil, follow: nil, height: nil, width: nil, output: false)
    @file = file || 'inputs/17.txt'
    @display = display
    @height = height
    @width = width
    @output = output
    @verbose = verbose
    @start = start || 0
    @stop = stop || Float::INFINITY
    @follow = follow
    @fast = fast
    @static_center = center
    @x_max = 0
    @y_max = 0
    @max_y_seen = 0
    @max_x_seen = 0
    @x_min = Float::INFINITY
    @y_min_flow = 0 # this has to start at zero because the highest clay is at 5
    @y_min_count = Float::INFINITY
    @min_y_seen = Float::INFINITY
    @min_x_seen = Float::INFINITY
    @grid = {}
    @queue = []
    @max_queue = 0
    @nearest_walls = {}
    @curr_pos = [nil, nil]
    @round = 0
    setup_grid!
  end

  ########
  # MAIN #
  ########
  def run
    until @queue.empty?
      q_len = @queue.length
      @max_queue = q_len if q_len > @max_queue
      @round += 1
      puts "#{'*' * 10} Round #{@round} #{'*' * 10}"
      puts "Queue: #{@queue}"
      success = process_queue!
      print_round_summary if success
      @queue.uniq.sort
    end
    print_final_summary
  end

  def process_queue!
    @curr_pos = @queue.shift
    update_seen_min_maxes!
    print_message "--> Current position: #{@curr_pos}"
    if out_of_bounds?(@curr_pos)
      print_message "\tOut of bounds: #{@curr_pos}, #{min_max}"
      raise 'FUCK' # this should never happen
    elsif still?(@curr_pos)
      print_message "\tAlready flipped: #{@curr_pos}"
      return false
    end
    make_next_move
    true
  end

  def add_to_queue!(pos)
    unless (clay?(pos) || @queue.include?(pos) || out_of_bounds?(pos))
      print_message " +\tAdding #{pos} to queue"
      @queue << pos
    end
  end

  def make_next_move
    %i(down left).each do |dir|
      next_pos = move(dir, @curr_pos)
      break if out_of_bounds?(next_pos)

      @curr_dir = dir
      @curr_state = '|'

      arrow = moving_down? ? 'v' : '<'
      print_message "#{arrow} Checking #{dir}ward move: #{next_pos}"
      if out_of_bounds?(next_pos)
        print_message "\tOut of bounds: #{next_pos}, #{min_max}"
        next
      end

      case @grid[next_pos]
      when nil
        print_message "\t\tFound empty space at position #{next_pos}"
        add_to_queue!(next_pos)
        break if moving_down?
      when '|'
        print_message "\t\tFound flowing water at position #{next_pos}"
        # if moving_down?
        print_message "\t\tAbandoning branch and ending round #{@round}"
        break if moving_down?
      when '~'
        # This should only be found on downward searches
        print_message "\t\tFound standing water at position #{next_pos}"
        @curr_state = '~'
        attempt_to_flip_row!(@curr_pos)
        next if moving_down?
      when '#'
        print_message "\t\tFound clay at position #{next_pos}"
        @curr_state = '~'
        attempt_to_flip_row!(@curr_pos)
        break if moving_down?
      end

    end
    update_grid_with_current_state!
    print_message "Round #{@round} finished"
  end

  def update_grid_with_current_state!
    return if @curr_pos == @start_pos
    @grid[@curr_pos] = @curr_state
  end

  def update_seen_min_maxes!
    @max_y_seen = @curr_pos[1] if @curr_pos[1] > @max_y_seen
    @max_x_seen = @curr_pos[0] if @curr_pos[0] > @max_x_seen
    @min_y_seen = @curr_pos[1] if @curr_pos[1] < @min_y_seen
    @min_x_seen = @curr_pos[0] if @curr_pos[0] < @min_x_seen
  end

  def water_count
    @grid.count { |k, v| %w(| ~).include?(v) && k[1] <= @y_max && k[1] >= @y_min_count }
  end

  ###########
  # DISPLAY #
  ###########

  def print_message(msg = nil, same_line: false)
    return if skip_some?
    return unless display? && @round >= @start
    same_line ? printf(msg) : puts(msg)
  end

  def print_grid(center: nil, width: 100, height: 20)
    @height ||= height
    @width ||= width
    center_x, center_y = adjust_center!(center)

    print_message "\ngrid center: #{[center_x, center_y]}"
    x_range ||= (center_x - @width / 2)..(center_x + @width / 2)
    y_range ||= (center_y - @height / 2)..(center_y + @height / 2)
    y_offset = y_range.first < 0 ? -y_range.first : 0
    y_range = (y_range.first + y_offset)..(y_range.last + y_offset)

    space = @fast ? ' ' : '.'.light_black
    green_vee = 'V'.green
    light_green_asterisk = '*'.light_green

    y_range.each do |y|
      print_message(y.to_s.ljust(5, ' '), same_line: true)
      x_range.each do |x|
        pos = [x, y]
        queued = pos == @curr_pos ? green_vee : nil
        queued ||= @queue.include?(pos) ? light_green_asterisk : nil

        if char = @grid[pos]
          print_message(queued || char, same_line: true)
        else
          print_message(queued || space, same_line: true)
        end
      end
      print_message
    end
  end

  def adjust_center!(center = nil)
    return (@center = @queue[@follow]) if @follow
    return (@center = @static_center) if @static_center
    # @last_center = @center.dup
    # @center = center
    # @center ||= @curr_pos if @curr_pos.all?
    # @center ||= @queue.first
    # return unless (@last_center + @center).all?
    #
    # last_x, last_y = @last_center
    # curr_x, curr_y = @center
    #
    # ∆x = last_x - curr_x
    # ∆y = last_y - curr_y
    #
    # ∆x = ∆x > 1 ? ∆x / 2 : ∆x < -1 ? ∆x / 2 : ∆x
    # ∆y = ∆y > 1 ? ∆y / 2 : ∆y < -1 ? ∆y / 2 : ∆y
    #
    # [curr_x + ∆x, curr_y + ∆y]
    @center = [
      (@queue.inject(0) { |agg, pos| agg + pos[0] } / @queue.length),
      (@queue.inject(0) { |agg, pos| agg + pos[1] } / @queue.length)
    ]
  end

  def skip_some?
    return false unless @fast
    @round % @fast != 0
  end

  def print_round_summary
    return unless display?
    return if skip_some?
    system 'clear'
    print_grid if @round >= @start

    puts("*" * 44)
    puts "Round #{@round} Summary"
    puts "\tQueue: #{@queue.length}"
    puts "\tMax queue: #{@max_queue}"
    unless @fast
      @queue.each_with_index do |pos, i|
        pos = pos.nil? ? 'nil' : pos
        i % 10 == 0 ? printf("\t\t") : nil
        i % 10 != 9 ? printf("#{pos} ") : puts(pos.to_s)
      end if display?
      puts
    end
    puts "\tGrid center: #{@center}"
    puts "\tCurrent position: #{@curr_pos}"
    puts "\tWater: #{water_count}"
    puts "\tClay: #{@grid.values.count { |el| el == '#' }}"
    puts "\tmin/max y seen: #{@min_y_seen}/#{@max_y_seen}"
    puts "\tmin/max x seen: #{@min_x_seen}/#{@max_x_seen}"
    puts "\t#{min_max}"
    puts("*" * 44)
    puts
    sleep 0.02 if display? && @round >= @start
    pause_display if @round == @stop
  end

  def print_final_summary
    puts("*" * 44)
    puts "Final summary"
    puts "Number of rounds: #{@rounds}"
    puts "#{min_max}"
    puts "\tmin/max y seen: #{@min_y_seen}/#{@max_y_seen}"
    puts "\tmin/max x seen: #{@min_x_seen}/#{@max_x_seen}"
    puts "\tMax y seen: #{@max_y_seen}"
    puts "\tGrid center: #{@center}"
    puts "\tWater: #{water_count}"
    print_grid_to_file! if @output
  end

  def print_grid_to_file!(file = 'artifacts/waterfall_grid.txt')
    x_range = (min_max[:x_min] - 1)..(min_max[:x_max] + 1)
    y_range = (min_max[:y_min_flow] - 1)..(min_max[:y_max] + 1)

    i = 1
    file_name, ext = file.split('.')
    while File.exist?("#{file_name}#{i}.#{ext}")
      i += 1
    end
    file = "#{file_name}#{i}.#{ext}"

    f = File.open(file, 'w+')
    y_range.each do |y|
      x_range.each do |x|
        f.printf(@grid[[x, y]] || ' ')
      end
      f.puts
    end
    f.close
  end

  def pause_display
    prompt =  "Enter [n] to go to next round\n"
    prompt += "      [c] to continue program\n"
    prompt += "      [x] to exit program"
    done = false

    until done
      # Only the else condition continues the loop, so set done => true here
      # and change it back to false there if necessary
      done = true
      puts prompt
      resp = gets.chomp[-1]
      case resp
      when 'n'
        @stop += 1
      when 'c'
        @stop = Float::INFINITY
      when 'x'
        @queue = []
      else
        puts "Invalid entry: #{resp}"
        done = false
      end
    end
  end

  def display?
    @display
  end

  def verbose?
    @verbose
  end

  #####################
  # ROWS & CONTAINERS #
  #####################
  def attempt_to_flip_row!(pos = nil)
    pos ||= @curr_pos
    print_message "? Try to flip row containing point: #{pos}"

    range = fill_range(pos)
    range && is_contained?(range) ? fill_row!(pos) : overflow!(pos)
  end

  def fill_row!(pos = nil)
    pos ||= @curr_pos
    print_message "#{@curr_state} Fill row at #{pos}"
    add_to_queue!(move(:up, pos))

    row_from_range[1...-1].each do |cell|
      print_message "\t #{@curr_state}\tSetting #{cell} to #{@curr_state}"
      add_to_queue!(move(:up, cell)) if flow?(cell)
      @grid[cell] = @curr_state
    end
  end

  def overflow!(pos = nil)
    pos ||= @curr_pos
    @curr_state = '|'
    %i(left right).each do |dir|
      this = pos.dup
      while floor?(this) && !clay?(this)
        @grid[this] = @curr_state
        this = move(dir, this)
      end
      # add_to_queue checks to make sure the pos isn't clay
      add_to_queue!(this)
    end
  end

  def row_from_range(range = nil, y = nil)
    range ||= fill_range
    return nil if range.nil?
    y ||= @curr_pos[1]
    range.map { |x| [x, y] }
  end

  def is_contained?(x_range = nil, y = nil)
    x_range ||= fill_range
    y ||= @curr_pos[1]
    print_message "\tis_contained? x range: #{x_range}, y: #{y}"
    if x_range.nil?
      print_message "\t\tInvalid range: #{x_range.nil? ? 'nil' : x_range}"
      return false
    end

    x_arr = x_range.to_a
    has_floor = x_arr[1...-1].all? { |x| floor?([x, y]) }
    print_message "\t\tHas floor: #{has_floor ? 'yes' : 'no'}"
    has_floor
  end

  def fill_range(pos = nil)
    pos ||= @curr_pos
    curr_walls = nearest_walls(*pos)
    unless curr_walls.all?
      print_message "\t\tCouldn't get one or both walls: #{curr_walls}"
      return nil
    end
    r = Range.new(*curr_walls)
    print_message "\tWalls range: #{r}"
    r
  end

  # Returns an array of the left and right wall's x-axis value
  def nearest_walls(x = nil, y = nil)
    x ||= @curr_pos[0]
    y ||= @curr_pos[1]
    if @nearest_walls[[x, y]]
      print_message "\tUsing cached nearest_walls for #{[x, y]}"
      return @nearest_walls[[x, y]]
    end
    print_message "\tFinding nearest walls for #{[x, y]}"
    walls = [nil, nil]

    %i(left right).each do |dir|
      print_message("\t\tChecking #{dir} side: ", same_line: true)
      this = [x, y]
      idx = dir == :left ? 0 : 1
      until clay?(this) || out_of_bounds?(this)
        this = move(dir, this)
      end
      # Leave wall nil if OOB
      print_message "#{this}"
      walls[idx] = this[0] unless out_of_bounds?(this)
    end
    cache_walls!(walls, [x, y])
    walls
  end

  def cache_walls!(walls, pos)
    @nearest_walls[pos] = walls
    if walls.all?
      y = pos[1]
      ((walls[0] + 1)..(walls[1] - 1)).each do |wall_x|
        @nearest_walls[[wall_x, y]] = walls
      end
    end
  end

  ############
  # MOVEMENT #
  ############
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

  ##########
  # SEARCH #
  ##########
  def clay?(pos = nil)
    pos ||= @curr_pos
    @grid[pos] == '#'
  end

  def floor?(pos)
    lower_pos = [pos[0], pos[1] + 1]
    still?(lower_pos) || clay?(lower_pos)
  end

  def flow?(pos = nil)
    pos ||= @curr_pos
    @grid[pos] == '|'
  end

  def still?(pos = nil)
    pos ||= @curr_pos
    @grid[pos] == '~'
  end

  def horizontal_flow_stopper?(pos)
    clay?(pos) || flow?(pos)
  end

  def empty?(pos = nil)
    pos ||= @curr_pos
    @grid[pos].nil?
  end

  def out_of_bounds?(pos = nil, count: false)
    y_min = count ? @y_min_count : @y_min_flow
    pos ||= @curr_pos
    vertical = pos[1] < y_min || pos[1] > @y_max
    horizontal = pos[0] < (@x_min - 1) || pos[0] > (@x_max + 1)
    horizontal || vertical
  end

  def min_max
    { x_min: @x_min, x_max: @x_max, y_min_count: @y_min_count, y_min_flow: @y_min_flow, y_max: @y_max }
  end

  #########
  # SETUP #
  #########
  def update_min_max!(x_arr, y_arr)
    @x_min = x_arr.min < @x_min ? x_arr.min : @x_min
    @y_min_flow = y_arr.min < @y_min_flow ? y_arr.min : @y_min_flow
    @y_min_count = y_arr.min < @y_min_count ? y_arr.min : @y_min_count
    @x_max = x_arr.max > @x_max ? x_arr.max : @x_max
    @y_max = y_arr.max > @y_max ? y_arr.max : @y_max
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

  def setup_grid!
    File.open(@file).readlines.map(&:chomp).each do |line|
      process_line!(line)
    end
    @start_pos = [500, 0]
    @center = @start_pos
    @grid[@start_pos] = '+'
    add_to_queue!(@start_pos)
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
end


def env(var_name, type = nil, sep = nil)
  var = ENV[var_name] || ENV[var_name.upcase] || ENV[var_name.downcase]
  case type
  when :integer
    var.nil? ? nil : var.to_i
  when :integer_array
    var.nil? ? nil : var.split(sep || '').map(&:to_i)
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
  kwargs[:verbose] = env('verbose', :boolean)
  kwargs[:output] = env('output', :boolean)
  kwargs[:follow] = env('follow', :integer)
  kwargs[:center] = env('center', :integer_array, ',')
  kwargs[:start] = env('start', :integer)
  kwargs[:stop] = env('stop', :integer)
  kwargs[:file] = env('file', :string)
  kwargs[:fast] = env('fast', :integer)
  kwargs[:width] = env('width', :integer)
  kwargs[:height] = env('height', :integer)

  wfh = WaterfallHell.new(**kwargs)
  wfh.print_grid(height: kwargs[:height] || 30, width: kwargs[:width] || 80)
  wfh.run
end

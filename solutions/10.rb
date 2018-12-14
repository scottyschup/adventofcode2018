class MessageFinder
  def initialize(verbose: false, **kwargs)
    @verbose = verbose
    @fps = (kwargs[:fps] || 10).to_i
    @iter = (kwargs[:iter] || 0).to_i
    @max_iter = (kwargs[:max_iter] || 1_000_000).to_i
    @pixel = kwargs[:pixel] || "#"
    @space = kwargs[:space] || " "
    @zoom = @prev_zoom = Float::INFINITY
    extract_start_info
  end

  def verbose?
    @verbose
  end

  def draw_grid(grid)
    grid.each_with_index do |row, i|
      if row.nil?
        puts("Row #{i}\t\t\t") if verbose?
        next
      end
      row_chars = row.map do |cell|
        cell ? @pixel : @space
      end
      puts("Row #{i}\t\t\t" + row_chars.join('')) if verbose?
    end
  end

  def place_coords
    grid = []
    current_positions = []
    @positions.each_with_index do |pos, i|
      x = pos[0] + @velocities[i][0] * @iter
      y = pos[1] + @velocities[i][1] * @iter
      current_positions << [x, y]
    end

    min_x = current_positions.map { |pos| pos[0] }.min
    min_y = current_positions.map { |pos| pos[1] }.min
    max_x = current_positions.map { |pos| pos[0] }.max
    max_y = current_positions.map { |pos| pos[1] }.max

    width = max_x - min_x
    height = max_y - min_y

    @prev_zoom = @zoom
    @zoom = height > 25 ? [height / 80, width / 30].max : 1

    current_positions.each do |pos|
      x = pos[0] - min_x
      y = pos[1] - min_y
      grid[y/@zoom] = grid[y/@zoom] || []
      grid[y/@zoom][x/@zoom] = true
    end
    grid
  end

  def extract_coords(str)
    # `str` is in the following format:
    # "position=<-3,  6>"
    coords_str = str.split('=')[1]
    coords_str.gsub!(/<\s?|>\s?/, "")
    coords_str_arr = coords_str.split(",")
    unless coords_str_arr.length == 2
      raise StandardError.new("extract_coords method broken: #{coords_str_arr}")
    end
    coords_str_arr.map(&:to_i)
  end

  def extract_start_info
    lines = File.open('inputs/10.txt').readlines
    @positions = []
    @velocities = []
    max_x, max_y = [-Float::INFINITY, -Float::INFINITY]
    min_x, min_y = [Float::INFINITY, Float::INFINITY]

    lines.each do |line|
      position, velocity = parse_line(line)
      max_x = [max_x, position[0]].max
      max_y = [max_y, position[1]].max
      min_x = [min_x, position[0]].min
      min_y = [min_y, position[1]].min

      @positions << position
      @velocities << velocity
    end
  end

  def parse_line(line)
    pos, vel = line.split(">\s")
    pos_x, pos_y = extract_coords(pos)
    vel_x, vel_y = extract_coords(vel)
    [[pos_x, pos_y], [vel_x, vel_y]]
  end

  def reached_target?
    if @prev_zoom < @zoom
      @iter -= @fps * 2
      print_details
      return true
    end
    @iter >= @max_iter
  end

  def print_details
    grid = place_coords
    system 'clear'
    puts "Iteration: #{@iter}"
    puts "Num rows (y): #{grid.length}"
    puts "Num cols (x): #{grid[0].length}"
    puts "Frames/second #{@fps}"
    puts "Zoom #{@zoom}"
    draw_grid(grid)

  end

  def run
    until reached_target?
      print_details if verbose?
      @iter += @fps
      sleep (0.2)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  verbose = ENV['VERBOSE'] != 'false' ? true : false
  mf = MessageFinder.new(verbose: verbose, fps: 5, iter: 10800)
  puts mf.run
end

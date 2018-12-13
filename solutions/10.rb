def env_var(var_name)
  env_var = ENV[var_name.upcase]
  (env_var.nil? || env_var.empty?) ? nil : env_var
end

def draw_grid(grid, pixel = nil, space = nil)
  grid.each_with_index do |row, i|
    if row.nil?
      puts('')
      next
    end
    row_chars = row.map do |cell|
      cell ? PIXEL : SPACE
    end
    puts("Row #{i}\t\t\t" + row_chars.join(''))
  end
end

def place_coords(positions, velocities, iter = 0)
  grid = []
  current_positions = []
  positions.each_with_index do |pos, i|
    x = pos[0] + velocities[i][0] * iter
    y = pos[1] + velocities[i][1] * iter
    current_positions << [x, y]
  end

  min_x = current_positions.map { |pos| pos[0] }.min
  min_y = current_positions.map { |pos| pos[1] }.min

  current_positions.each do |pos|
    x = pos[0] - min_x
    y = pos[1] - min_y
    grid[x/ZOOM] = grid[x/ZOOM] || []
    grid[x/ZOOM][y/ZOOM] = true
  end
  grid
end

def extract_coords(str)
  # `str` input: "position=<-3,  6>"
  coords_str = str.split('=')[1]
  coords_str.gsub!(/<\s?|>\s?/, "")
  coords_str_arr = coords_str.split(",")
  unless coords_str_arr.length == 2
    raise StandardError.new("extract_coords method broken: #{coords_str_arr}")
  end
  coords_str_arr.map(&:to_i)
end

def parse_line(line)
  pos, vel = line.split(">\s")
  pos_x, pos_y = extract_coords(pos)
  vel_x, vel_y = extract_coords(vel)
  [[pos_x, pos_y], [vel_x, vel_y]]
end

PIXEL = env_var('pixel_char') || "#"
SPACE = env_var('space_char') || " "
FPS = (env_var('fps') || 10).to_i
ITER = (env_var('iter') || 0).to_i
ZOOM = (env_var('zoom') || 1).to_i

lines = File.open('inputs/10.txt').readlines
positions = []
velocities = []
max_x, max_y = [-Float::INFINITY, -Float::INFINITY]
min_x, min_y = [Float::INFINITY, Float::INFINITY]

lines.each do |line|
  position, velocity = parse_line(line)
  max_x = [max_x, position[0]].max
  max_y = [max_y, position[1]].max
  min_x = [min_x, position[0]].min
  min_y = [min_y, position[1]].min

  positions << position
  velocities << velocity
end

i = j = ITER
while i == j
# while true
  system 'clear'
  puts "Iteration: #{i}"
  grid = place_coords(positions, velocities, i)
  # puts "Num rows (x): #{grid.length}"
  # puts "Num cols (y): #{grid[0].length}"
  draw_grid(grid)
  i += 1
  puts FPS
  sleep (1.0 / FPS)
end

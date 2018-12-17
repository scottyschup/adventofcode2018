input = File.open("inputs/17#{ENV['TEST'].nil? ? '' : '_test'}.txt").readlines.map(&:chomp)
# grid = []
clay = {}
water = {}
resources = { clay: clay, water: water }
x_min, x_max, y_max, y_max = [Float::INFINITY, 0, Float::INFINITY, 0]

# read file into clay hash
input.each do |line|
  coords = []
  line.split(', ').sort.each do |coord|
    coords << coord.split('=').last
  end
  coords.map! do |n_str|
    nums = n_str.split('..').map(&:to_i)
    nums.length > 1 ? Range.new(*nums) : nums[0]
  end

  x_coord, y_coord = coords

  if x_coord.is_a?(Range)
    y = y_coord
    y_max = y if y > y_max
    x_coord.to_a.each do |x|
      x_max = x if x > x_max
      x_min = x if x < x_min
      clay[[x, y]] = true
    end
  elsif y_coord.is_a?(Range)
    x = x_coord
    x_max = x if x > x_max
    x_min = x if x < x_min
    y_coord.to_a.each do |y|
      y_max = y if y > y_max
      clay[[x, y]] = true
    end
  end
end

p min_max = { x_max: x_max, x_min: x_min, y_max: y_max }

DELTAS = {
  up: [0, -1],
  down: [0, 1],
  left: [-1, 0],
  right: [1, 0]
}

def apply_delta(pos, delta)
  x, y = pos
  ∆x, ∆y = delta
  [x + ∆x, y + ∆y]
end

def empty?(pos, clay:, water:, **kwargs)
  clay[pos].nil? && water[pos].nil?
end

def out_of_bounds?(pos, x_min:, x_max:, y_max:, **kwargs)
  x, y = pos
  x < x_min || x > x_max || y > y_max
end

def in_bounds?(pos, **kwargs)
  !out_of_bounds?(pos, **kwargs)
end

def can_move?(dir, pos, **kwargs)
  new_pos = apply_delta(pos, DELTAS[dir])
  empty?(new_pos, **kwargs) && in_bounds?(new_pos, **kwargs)
end

def clay_or_water?(pos, clay:, water:, **kwargs)
  clay[pos] || water[pos]
end

def move(dir, pos)
  apply_delta(pos, DELTAS[dir])
end

spring_tips = [[500, 1]]

# arr.inject([]) { |agg, n| if n[0] % 2 == 0; next agg << [n[0], n[1]*2]; end; agg << n }
# => [[1, 2], [2, 6], [3, 4]]
i = 0
limit = ENV['LIMIT']
limit = limit.nil? ? Float::INFINITY : limit.to_i

until spring_tips.empty? || i >= limit
  i += 1
  spring_tips = spring_tips.inject([]) do |agg, tip|
    water[tip] = true

    if can_move?(:down, tip, **resources, **min_max)
      new_tip = move(:down, tip)
      water[new_tip] = true
      next agg << new_tip
    elsif tip[1] >= y_max
      next agg
    else
      walls = 0
      %i(left right).each do |dir|
        curr_tip = tip
        hit_wall = no_floor = out_of_bounds = false

        until no_floor || hit_wall
          next_tip = move(dir, curr_tip)
          if can_move?(dir, curr_tip, **resources, **min_max)
            curr_tip = next_tip
            water[curr_tip] = true
            if can_move?(:down, curr_tip, **resources, **min_max)
              no_floor = true
              agg << curr_tip if no_floor
            end
          elsif clay_or_water?(next_tip, **resources)
            hit_wall = true
            walls += 1
          elsif out_of_bounds?(next_tip, **min_max)
            hit_wall = true
          end
        end
      end
      agg << move(:up, tip) if walls == 2
      agg
    end
  end

  puts "Round: #{i}"
  puts "Min x: #{x_min}, Max x: #{x_max}, Max y: #{y_max}"
  puts "\tClay: #{clay.length}"
  puts "\tWater: #{water.length}"
  p water.keys if ENV['VERBOSE'].to_i == 1
  puts "\tQueue: #{spring_tips.length}"
  p spring_tips if ENV['VERBOSE'].to_i == 1
  puts
end

puts "iters: #{i}"
puts "clay: #{clay.length}"
puts "water: #{water.length}"
p water.keys if ENV['VERBOSE'].to_i == 1
puts "Min x: #{x_min}, Max x: #{x_max}, Max y: #{y_max}"

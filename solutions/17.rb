def print_grid!(center: [], clay:, water:, queue:, x_range: nil, y_range: nil, width: 100, height: 15)
  x, y = center
  x_range ||= (x - width / 2)..(x + width / 2)
  y_range ||= (y - height / 2)..(y + height / 2)
  y_offset = y_range.first < 0 ? -y_range.first : 0
  y_range = (y_range.first + y_offset)..(y_range.last + y_offset)

  y_range.each do |y|
    x_range.each do |x|
      pos = [x, y]
      queued = queue.include?(pos) ? 'V' : nil

      if clay[pos]
        printf(queued || '#') # this should never be queued, but here to catch errors
      elsif water[pos]
        printf(queued || (water[pos] == :flow ? '|' : '~'))
      else
        printf(queued || '.')
      end
    end
    puts
  end
end

def print_grid?
  ENV['PRINT_GRID']
end

input = File.open("inputs/17#{ENV['TEST'].nil? ? '' : '_test'}.txt").readlines.map(&:chomp)
# grid = []
clay = {}
water = {}
resources = { clay: clay, water: water }
x_min, x_max, y_max, max_y_seen = [Float::INFINITY, 0, 0, 0]

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

def clay?(pos, clay:, **kwargs)
  clay[pos]
end

def flow?(pos, water:, **kwargs)
  water[pos] == :flow
end

def stagnant?(pos, water:, **kwargs)
  water[pos] && !flow?(pos, water: water, **kwargs)
end

def move(dir, pos)
  apply_delta(pos, DELTAS[dir])
end

def find_branch_point(pos, water:, clay:)
  puts("\tFinding branch point for #{pos}") if print_grid?
  above = move(:up, pos)
  i = 0
  dir = :left
  curr_above = above
  puts("\t\tpossible branch:   #{curr_above}: #{flow?(curr_above, water: water) ? 'yes' : 'no'}") if print_grid?
  until flow?(curr_above, water: water)
    curr_above = above
    i.times do
      curr_above = move(dir, curr_above)
    end
    puts("\t\tpossible branch:   #{curr_above}: #{flow?(curr_above, water: water) ? 'yes' : 'no'}") if print_grid?
    dir = dir == :left ? :right : :left
    i += 1 if dir == :left
  end

  puts("\tThe Chosen Branch™: #{curr_above}") if print_grid?
  puts if print_grid?
  curr_above
end

def handle_colliding_tips(tips, water:, clay:, **kwargs)
  tips.reverse!
  done = false
  until done
    done = true
    tips = tips.each_with_index.map do |tip, i|
      altered = nil
      removed = false
      tips[(i + 1)..-1].each do |t|
        puts("comparing #{tip}, #{t}") if print_grid?
        if tip[1] == t[1] && will_collide?(tip, t, clay: clay, water: water)
          if pool_with_alternate_source?(tip, water: water, clay: clay, **kwargs)
            removed = true
            done = false
            break
          else
            altered ||= move(:up, tip)
            done = false
            break
          end
          puts "won't collide" if print_grid?
          puts if print_grid?
        else
          puts "\tNo collisions found"
        end
      end

      puts "\tAltered: #{move(:down, altered)} => #{altered}" if altered
      puts "\tRemoved: #{tip}" if removed
      altered || (removed ? nil : tip)
    end.compact
  end
  tips.reverse!
end

def will_collide?(a, b, clay:, water:)
  a, b = [a, b].sort { |x, y| x[0] <=> y[0] }
  puts "\twill_collide?: #{a}, #{b}" if print_grid?
  unless a[1] == b[1]
    puts "\t\tMismatched y-axes: #{a[1]} != #{b[1]}" if print_grid?
    return false
  end
  ax, y = a
  bx, _ = b

  x_range = (ax..bx)
  if x_range.to_a.empty?
    puts "\t\tEmpty x_range: #{ax}, #{bx}" if print_grid?
    return false
  end
  floor = x_range.all? do |x|
    pos = [x, y + 1]
    clay?(pos, clay: clay) || stagnant?(pos, water: water)
  end
  barriers = x_range.any? do |x|
    pos = [x, y]
    clay?(pos, clay: clay) || stagnant?(pos, water: water)
  end

  puts "\t\tFloor:    #{floor ? 'yes' : 'no'}" if print_grid?
  puts "\t\tBarriers: #{barriers ? 'yes' : 'no'}" if print_grid?
  puts "\tWill collide? #{(floor && !barriers) ? 'yes' : 'no'}"

  floor && !barriers
end

def find_nearest_walls(pos, water:, clay:, **kwargs)
  puts "\tNearest walls:" if print_grid?
  nearest_walls = []
  %i(left right).each do |dir|
    curr_pos = pos
    until clay?(curr_pos, clay: clay)
      if out_of_bounds?(curr_pos, **kwargs)
        puts "\tcurrent position out of bounds #{curr_pos}"
        return nil
      end
      curr_pos = move(dir, curr_pos)
    end
    nearest_walls << curr_pos[0]
  end
  nearest_walls.sort!
  left, right = nearest_walls
  puts "\t\tleft: #{[left, pos[1]]}" if print_grid?
  puts "\t\tright:#{[right, pos[1]]}" if print_grid?
  nearest_walls
end

def pool_with_alternate_source?(pos, clay:, water:, **kwargs)
  puts "\tpool_with_alternate_source?" if print_grid?
  nearest_walls = find_nearest_walls(pos, clay: clay, water: water, **kwargs)
  return false unless nearest_walls
  left, right = nearest_walls
  walls_range = ((left + 1)...right).to_a
  is_pool = walls_range.all? do |x|
    curr_floor = [x, pos[1] + 1]
    stagnant?(curr_floor, water: water)
  end

  unless is_pool
    puts "\tSource found: no (not a pool)"
    return false
  end

  puts "\tFind own source" if print_grid?
  own_source = find_branch_point(pos, clay: clay, water: water)
  # own_source = find_branch_point(own_source, clay: clay, water: water)

  exes = walls_range.to_a - [pos[0], own_source[0]]
  # Single point of entry means no alternate source
  if exes.empty?
    puts "\tSource found: no (single point of entry)" if print_grid?
    return false
  end

  has_source = exes.any? do |x|
    flow?([x, pos[1]], water: water) || flow?([x, pos[1] - 1], water: water)
  end
  puts "\tSource found: #{has_source ? 'yes' : 'no (no flow)'}" if print_grid?
  has_source
end

def contained_pool_with_flow?(pos, queue, water:, clay:)
  puts "contained_pool_with_flow?"
  walls = 0
  i = 0
  dirs = %i(left right)
  seen = {}

  until walls == 2
    to_delete = nil
    dirs.each do |dir|
      curr_floor = move(:down, pos)
      curr_look_ahead = move(dir, pos)
      i.times do
        curr_floor = move(dir, curr_floor)
        curr_look_ahead = move(dir, curr_look_ahead)
      end
      unless stagnant?(curr_floor, water: water)
        puts "\tContained pool: no"
        return false
      end
      if clay?(curr_look_ahead, clay: clay)
        walls += 1
        to_delete = dir
      end
      seen[curr_look_ahead] = true
    end
    dirs.delete(to_delete) unless to_delete.nil?
    i += 1
  end
  puts "\tContained pool: yes"
  sources = queue.select { |el| seen[pos] }
  if sources.empty?
    puts "\tAlternate source: no"
    puts
    false
  else
    puts "\tAlternate source: yes #{sources}"
    puts
    true
  end
end


if __FILE__ == $PROGRAM_NAME
  spring_tips = [[500, 1]]

  i = 0
  limit = ENV['LIMIT']
  limit = limit.nil? ? Float::INFINITY : limit.to_i

  until spring_tips.empty? || i >= limit
    i += 1
    puts "**************** ROUND #{i} ****************"
    puts "QUEUE: #{spring_tips}"
    spring_tips = spring_tips.inject([]) do |agg, tip|
      puts "--> Current tip: #{tip}"
      max_y_seen = tip[1] > max_y_seen ? tip[1] : max_y_seen
      water[tip] = :flow

      # Check if water can move down one space
      new_tip = move(:down, tip)
      if can_move?(:down, tip, **resources, **min_max)
        puts "\tCAN MOVE"
        if !agg.empty? && agg.any? { |t| will_collide?(t, new_tip, **resources) }
          puts "WON'T MOVE TO AVOID COLLISION"
          next agg << tip
        end
        # if can move without collision, start there on the next iteration
        next agg << new_tip
      elsif out_of_bounds?(new_tip, **min_max)
        puts "\tOUT OF BOUNDS"
        # if the next space down is the bottom, end this iteration
        next agg
      elsif flow?(new_tip, water: water)
        puts "\tINTO FLOW"
        next agg
      # elsif stagnant?(new_tip, water: water) && full_pool?(new_tip, **resources)
      # elsif contained_pool_with_flow?(new_tip, agg, water: water, clay: clay)
      elsif pool_with_alternate_source?(tip, **resources, **min_max)
        puts "\tPOOL WITH ALT SRC #{tip}"
        next agg
      else
        puts "\tSPREAD OUT"
        # if the next space down is not empty or out of bounds,
        # it must be clay or water, so flow goes left and right

        # If flow gets caught by walls on either end, it becomes stagnant
        # But if one or both ends are open, the flow continues

        # Keep track of flow in a temp array until either 2 walls, an open side,
        # or the end of the board has been found, then either leave as flow or
        # convert to stagnant water after left and right have both been checked
        tmp = []
        walls = 0
        %i(left right).each do |dir|
          curr_tip = tip # curr_tip is already accounted for in water
          no_floor = hit_something = false
          no_change = 0

          until no_floor || hit_something || no_change > 1
            # If next space left or right is free, water fills it
            next_tip = move(dir, curr_tip)
            if can_move?(dir, curr_tip, **resources, **min_max)
              tmp << next_tip
              # But if the space below it is empty, the water continues flowing
              if can_move?(:down, next_tip, **resources, **min_max)
                no_floor = true
                agg << next_tip
              else
                tmp << curr_tip
              end
              # Set current to next for next iteration
              curr_tip = next_tip

            # Or if the next step is flowing water, see if there's a wall on the
            # other side of the flow, and if not, abandon branch
            elsif flow?(next_tip, water: water)
              tmp << curr_tip
              wall = hole = false
              look_ahead = next_tip
              until wall || hole
                tmp << look_ahead
                look_ahead = move(dir, look_ahead)
                wall = clay?(look_ahead, clay: clay)
                look_ahead_floor = move(:down, look_ahead)
                hole = empty?(look_ahead_floor, clay: clay, water: water) || flow?(look_ahead_floor, water: water)
              end

              if wall
                hit_something = true
                walls += 1
              else
                no_floor = true
              end

            # Or if the next step is clay, a wall has been found
            elsif clay?(next_tip, clay: clay)
              tmp << curr_tip
              hit_something = true
              walls += 1
            # Or if the next step is off the board, abandon that branch
            elsif out_of_bounds?(next_tip, **min_max)
              tmp << curr_tip
              hit_something = true
            else
              no_change += 1
            end
          end

        end

        # If walls were hit on both sides, convert temp array positions
        # into stagnant water (i.e. `water[pos] = true`)
        # otherwise ensure they are all set as flowing (i.e. `water[pos] = :flow`)
        tmp.uniq!
        if walls == 2
          puts "\tLEVEL UP"
          puts("\t\tTMP AGG overlap: #{tmp.select { |el| agg.include?(el) }}")
          tmp.each do |t|
            water[t] = true
            while idx = agg.index(t)
              puts("\t\tBacking up: #{t} => #{move(:up, t)}")
              water[agg[idx]] = true
              agg[idx] = move(:up, t)
            end
          end
          agg << find_branch_point(tip, **resources)
        else
          tmp.each { |t| water[t] = :flow }
        end

        # Don't forget to return aggregator of current branches to check on next iteration
        agg.sort { |x, y| x[1] <=> y[1] }.sort{ |x, y| x[0] <=> y[0] }
      end
    end
    # Resolve any potential collisions
    puts("Pre-collision-check: #{spring_tips}")
    spring_tips = handle_colliding_tips(spring_tips.uniq, **resources, **min_max)
    puts("Post-collision-check: #{spring_tips}")

    next if spring_tips.empty?

    start_at = ENV['START_AT'].to_i
    stop_at ||= ENV['STOP_AT'].to_i
    stop_at = stop_at.zero? ? Float::INFINITY : stop_at
    next unless i >= start_at

    # Round summary
    system 'clear'
    print_grid = ENV['PRINT_GRID'].to_i
    if print_grid == 1
      # begin
        env_center = ENV['CENTER']
        env_center = env_center.split(',').map(&:to_i) if env_center
        follow = ENV['FOLLOW'].to_i
        center = env_center || spring_tips[follow]
        print_grid!(center: center, queue: spring_tips, **resources)
      # rescue NoMethodError => e
      #   puts e
      # end
    end

    puts("*" * 44)
    puts "Round #{i} Summary"
    puts "Board: min x: #{x_min}, max x: #{x_max}, max y: #{y_max}"
    puts "\tmax y seen: #{max_y_seen}"
    puts "\tGrid center: #{center}"
    puts "\tClay: #{clay.length}"
    puts "\tWater: #{water.length}"
    puts "\tQueue: #{spring_tips.length}"

    spring_tips.each_with_index do |tip, i|
      tip = tip.nil? ? 'nil' : tip
      i % 10 != 9 ? print("#{tip} ") : puts(tip.to_s)
    end
    puts
    puts("*" * 44)
    puts
    sleep 0.03 if print_grid == 1

    if i >= stop_at
      prompt = "Enter [n] to go to next round\n      [c] to continue program\n      [x] to exit program"
      done = false

      until done
        puts prompt
        resp = gets.chomp
        case resp
        when 'n'
          stop_at += 1
          done = true
        when 'c'
          stop_at = Float::INFINITY
          done = true
        when 'x'
          spring_tips = []
          done = true
        else
          puts "Invalid entry: #{resp}"
        end
      end
    end
  end

  # Final summary
  puts
  puts "FINAL SUMMARY"
  puts "Board: min x: #{x_min}, max x: #{x_max}, max y: #{y_max}"
  puts "iters: #{i}"
  puts "clay: #{clay.length}"
  puts "water: #{water.length}"
  p water.keys if ENV['VERBOSE'].to_i == 1
end

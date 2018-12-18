  class Waterhell
  def parse_line(agg, line)
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
      x_coord.to_a.map do |x|
        agg[[x, y_coord]] = '#'
      end
    elsif y_coord.is_a?(Range)
      y_coord.to_a.each do |y|
        agg[[x_coord, y]] = '#'
      end
    end
    agg
  end

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
end

input = File.open("inputs/17#{ENV['TEST'].nil? ? '' : '_test'}.txt").readlines.map(&:chomp)
x_min, x_max, y_max, max_y_seen = [Float::INFINITY, 0, 0, 0]

grid = input.inject({}) do |agg, line|
  parse_line(agg, line)
end

min_max = { x_max: x_max, x_min: x_min, y_max: y_max }


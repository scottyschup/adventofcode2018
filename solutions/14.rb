class Player
  attr_accessor :scoreboard_index, :current_score

  def initialize(name:, scoreboard_index:, current_score:)
    @name = name
    @scoreboard_index = scoreboard_index.to_i
    @current_score = current_score.to_i
  end

  def moves
    current_score + 1
  end

  def adjust_index!(delta)
    @scoreboard_index -= delta
  end
end

class RecipeGame
  def initialize(test_recipes: Float::INFINITY, target_pattern: nil, initial_scoreboard: [3, 7])
    @test_recipes = test_recipes
    @target_number_recipes = test_recipes + 10
    @scoreboard = initial_scoreboard
    @pattern_index = nil
    if target_pattern
      if target_pattern.is_a?(Integer)
        puts 'Warning: input is an Integer; any leading zeros will be lost!'
        puts "\tand the resulting index will be off by the number of leading zeros"
      end
      @target_pattern = target_pattern.to_s
      @target_length = @target_pattern.length
      @last_score = ''
      @last_index = -@target_length
    end
    check_new_recipes!(initial_scoreboard)
    setup_players!
  end

  def setup_players!
    @players = [
      Player.new(name: "Player 1", scoreboard_index: 0, current_score: @scoreboard[0]),
      Player.new(name: "Player 2", scoreboard_index: 1, current_score: @scoreboard[1])
    ]
  end

  def add_to_scoreboard!(n_arr)
    new_score_arr = n_arr.is_a?(Array) ? n_arr : [n_arr]
    unless new_score_arr.all? { |el| el.is_a?(Integer) && el < 10 }
      raise StandardError.new("RecipeGame#add_to_scoreboard: array malformed\n\tclass: #{n_arr[0].class}\n\tvalue: #{n_arr}")
    end
    @scoreboard += new_score_arr
  end

  def check_new_recipes(n_arr)
    n_arr.map(&:to_s).each do |char|
      @last_score = (@last_score + char).split('').last(6).join('')
      @last_index += 1
      @pattern_index = @last_score == @target_pattern ? @last_index : @pattern_index
    end
  end

  def run(verbose: false)
    @verbose = verbose
    @round = 0
    @progress = 0
    @start_time = Time.now
    @seen = 0

    until target_reached? || @pattern_index # || pattern_found?
      tick
      @round += 1
    end

    puts "seen: #{@seen}"
    @pattern_index || @scoreboard.slice(@test_recipes, 10).join('')
  end

  def tick
    puts("Round: #{@round}\t\t#{@scoreboard}") if verbose?
    @step_amount = @target_number_recipes / 100
    curr_time = Time.now - @start_time
    mins, secs = curr_time.divmod 60
    hours, mins = mins.divmod 60
    if !@step_amount.zero? && @scoreboard.length / @step_amount > @progress
      @progress = @scoreboard.length * 100 / @target_number_recipes
      system('clear')
      puts "Progress:#{'*' * @progress}#{' ' * ([100 - @progress, 0].max)}|| #{@progress}%"
      puts "\t#{"%02d" % hours}:#{"%02d" % mins}:#{"%02d" % secs}"
    end
    if @target_pattern && @seen > 1 && @seen % 10000 <= 1
      system('clear')
      puts "Current start index: #{@seen}"
      puts "\t#{"%02d" % hours}:#{"%02d" % mins}:#{"%02d" % secs}"
    end

    target_pattern ?
      check_new_recipes(create_new_recipes) :
      add_to_scoreboard!(create_new_recipes)
    move_players!
  end

  def verbose?
    @verbose
  end

  def target_reached?
    @scoreboard.length >= @target_number_recipes
  end

  def pattern_found?
    return false if @target_pattern.nil? || @target_pattern.empty?
    return false if @scoreboard.length - 10 < @target_pattern.length
    @pattern_index = @scoreboard[@seen..-1].join('').index(@target_pattern)
    @pattern_index += @seen if @pattern_index
    @seen = @scoreboard.length - @target_pattern.length - 10
    @pattern_index
  end

  def create_new_recipes
    combined_score = 0
    @players.each { |player| combined_score += player.current_score }
    combined_score.to_s.split('').map(&:to_i)
  end

  def move_players!
    @players.each do |player|
      new_index = (player.scoreboard_index + player.moves) % @scoreboard.length
      player.scoreboard_index = new_index
      player.current_score = @scoreboard[new_index]
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  # INPUT: 513401
  verbose = ENV['VERBOSE'] == 'true'
  target_num = (ENV['TARGET_NUM'] || 513401).to_i
  target_pattern = ENV['TARGET_PATTERN'] || '513401'
  # Part 1
  # rg = RecipeGame.new(test_recipes: target_num, initial_scoreboard: [3, 7])
  rg = RecipeGame.new(target_pattern: target_pattern, initial_scoreboard: [3, 7])
  puts rg.run(verbose: verbose)
end

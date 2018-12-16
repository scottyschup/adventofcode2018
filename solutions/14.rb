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

  def scoreboard_coords
    @scoreboard_index.divmod(10_000).join(',')
  end
end

class RecipeGame
  def initialize(test_recipes: , target_pattern: nil, initial_scoreboard: [3, 7])
    @test_recipes = test_recipes
    @target_number_recipes = test_recipes + 10
    @scoreboard = {}
    @scoreboard_length = 0
    @pattern_index = nil
    @target_pattern = target_pattern ? target_pattern.to_s : nil

    if search?
      @target_length = @target_pattern.length
      @last_score = ''
      @last_index = -@target_length
      check_new_recipes!(initial_scoreboard)
    end

    add_to_scoreboard!(initial_scoreboard)
    setup_players!
  end

  def search?
    !@target_pattern.nil?
  end

  def setup_players!
    @players = [
      Player.new(name: "Player 1", scoreboard_index: 0, current_score: @scoreboard['0']),
      Player.new(name: "Player 2", scoreboard_index: 1, current_score: @scoreboard['1'])
    ]
  end

  def add_to_scoreboard!(n_arr)
    n_arr.map(&:to_s).each do |char|
      @scoreboard[@scoreboard_length.to_s] = char
      @scoreboard_length += 1
    end
  end

  def check_new_recipes!(n_arr)
    return unless search?
    n_arr.map(&:to_s).each do |char|
      @last_score = (@last_score + char).split('').last(@target_length).join('')
      @last_index += 1
      @pattern_index = @last_score == @target_pattern ? @last_index : @pattern_index
    end
  end

  def verbose?
    !!@verbose
  end

  def target_reached?
    @scoreboard_length >= @target_number_recipes
  end

  def pattern_index_found?
    !!@pattern_index
  end

  def create_new_recipes
    combined_score = 0
    @players.each { |player| combined_score += player.current_score }
    combined_score.to_s.split('').map(&:to_i)
  end

  def move_players!
    @players.each do |player|
      new_index = (player.scoreboard_index + player.moves) % @scoreboard_length
      player.scoreboard_index = new_index
      player.current_score = @scoreboard[new_index.to_s].to_i
    end
  end

  def tick
    puts("Round: #{@round}\t\tLength: #{@scoreboard_length}") if verbose?
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

    if search? && @scoreboard_length % 10000 <= 1
      system('clear')
      puts "Current start index: #{@scoreboard_length}"
      puts "\t#{"%02d" % hours}:#{"%02d" % mins}:#{"%02d" % secs}"
    end

    new_recipes = create_new_recipes
    check_new_recipes!(new_recipes) if search?
    add_to_scoreboard!(new_recipes)
    move_players!
  end

  def next_n_chars(n)
    (0..n - 1).map { |delta| @scoreboard[(@test_recipes + delta).to_s] }.join('')
  end

  def run(verbose: false)
    @verbose = verbose
    @round = 0
    @progress = 0
    @start_time = Time.now

    until search? ? pattern_index_found? : target_reached?
      tick
      @round += 1
    end

    puts "scoreboard length: #{@scoreboard_length}"
    @pattern_index || next_n_chars(10)
  end
end

if __FILE__ == $PROGRAM_NAME
  # INPUT: 513401
  truthy = [1, '1', 'true', 'TRUE', 't', 'T', 'True']
  verbose = truthy.include? ENV['VERBOSE']
  test_recipes = ENV['TEST_RECIPES'] || 0
  test_recipes = test_recipes.to_i if test_recipes
  target_pattern = ENV['TARGET_PATTERN']
  rg = RecipeGame.new(test_recipes: test_recipes, target_pattern: target_pattern, initial_scoreboard: [3, 7])
  puts rg.run(verbose: verbose)
end

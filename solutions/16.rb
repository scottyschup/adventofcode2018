class Device
  NAMED_OPCODES = {
    addr: Proc.new { |reg, a, b, c| reg[c] = reg[a] + reg[b] },
    addi: Proc.new { |reg, a, b, c| reg[c] = reg[a] + b },
    mulr: Proc.new { |reg, a, b, c| reg[c] = reg[a] * reg[b] },
    muli: Proc.new { |reg, a, b, c| reg[c] = reg[a] * b },
    banr: Proc.new { |reg, a, b, c| reg[c] = reg[a] & reg[b] },
    bani: Proc.new { |reg, a, b, c| reg[c] = reg[a] & b },
    borr: Proc.new { |reg, a, b, c| reg[c] = reg[a] | reg[b] },
    bori: Proc.new { |reg, a, b, c| reg[c] = reg[a] | b },
    setr: Proc.new { |reg, a, b, c| reg[c] = reg[a] },
    seti: Proc.new { |reg, a, b, c| reg[c] = a },
    gtir: Proc.new { |reg, a, b, c| reg[c] = a > reg[b] ? 1 : 0 },
    gtri: Proc.new { |reg, a, b, c| reg[c] = reg[a] > b ? 1 : 0 },
    gtrr: Proc.new { |reg, a, b, c| reg[c] = reg[a] > reg[b] ? 1 : 0 },
    eqir: Proc.new { |reg, a, b, c| reg[c] = a == reg[b] ? 1 : 0 },
    eqri: Proc.new { |reg, a, b, c| reg[c] = reg[a] == b ? 1 : 0 },
    eqrr: Proc.new { |reg, a, b, c| reg[c] = reg[a] == reg[b] ? 1 : 0 }
  }

  attr_accessor :samples, :program, :registers, :analyses, :counts

  def initialize(file: 'inputs/16.txt')
    @registers = []
    @samples = []
    @program = []
    @codename_map = {}
    parse_input(file)
  end

  def reset!
    @ambiguous = 0
    @registers = []
    @analyses = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = 0 } }
    @counts = []
    @possible_codes = Hash.new { |h, k| h[k] = [] }
    @codename_map = {}
  end

  def parse_input(file)
    next_idx = 0
    File.open(file).readlines.each_with_index do |line, idx|
      next if line.gsub("\n", "").empty?
      if idx < next_idx
        @samples[idx / 4] << array_from_str(line)
      elsif idx >= next_idx
        if line.start_with?('Before')
          @samples[idx / 4] = [array_from_str(line)]
          next_idx = idx + 4
        else
          @program << array_from_str(line)
        end
      end
    end
  end

  def array_from_str(str)
    if str.include?('Before') || str.include?('After')
      str = str.split(/:\s*/)[1]
    end
    str.gsub(/[\[\],]/, '').split(' ').map(&:to_i)
  end

  def analyze_samples!
    reset!
    @samples.each_with_index do |sample, idx|
      count = 0
      before, instructions, after = sample

      NAMED_OPCODES.each do |codename, operation|
        @registers = before.dup
        code, a, b, c = instructions
        operation.call(@registers, a, b, c)
        if @registers == after
          count += 1
          @analyses[codename][code] += 1
          @possible_codes[codename] << code
        end
      end

      @counts[idx] = count
      @ambiguous += 1 if count >= 3
    end
    reduce_possible_codes!
    puts @ambiguous
  end

  def reduce_possible_codes!
    updated = true
    @possible_codes.each { |name, arr| arr.uniq! }
    while updated
      updated = false
      @possible_codes.each do |_name, arr|
        @codename_map.each do |code, _name|
          updated = arr.delete(code).nil? ? updated : true
        end
      end
      @possible_codes.each do |name, arr|
        if arr.length == 1
          @codename_map[arr[0]] = name
          updated = true
        end
      end
    end

    puts "Ambiguous: #{@possible_codes}"
    puts "Known: #{@codename_map.sort { |x, y| x[0] <=> y[0] }}"
  end

  def print_analyses
    @analyses.each do |codename, anal|
      puts codename
      sorted = anal.sort { |x, y| y[1] <=> x[1] }.to_h
      sorted.each { |k, v| puts "\t#{k}: #{v}" }
    end
  end

  def run
    analyze_samples! if @codename_map.empty?
    # @registers = [0, 0, 0, 0]
    @program.each do |instructions|
      code, a, b, c = instructions
      codename = @codename_map[code]
      NAMED_OPCODES[codename].call(@registers, a, b, c)
    end
    puts "Registers: #{@registers}"
  end
end

if __FILE__ == $PROGRAM_NAME
  Device.new.run
end

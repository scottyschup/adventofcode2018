def has_n_repeated_chars(n, str)
  chars = Hash.new { |h, k| h[k] = 0 }
  str.split('').each do |char|
    chars[char] += 1
  end

  chars.values.any? { |el| el == n }
end

input = File.new('./inputs/02.txt').readlines()
twos = []
threes = []

input.each do |code|
  twos << code.strip if has_n_repeated_chars(2, code)
  threes << code.strip if has_n_repeated_chars(3, code)
end

puts twos.length * threes.length

list = twos + threes
match = nil

list.each_with_index do |code, idx|
  list[(idx + 1)..-1].each do |kode|
    strikes = 0
    code.length.times do |n|
      break if strikes > 1
      strikes += 1 unless code[n] == kode[n]
    end
    if strikes == 1
      match = [code, kode]
      break
    end
  end
  break unless match.nil?
end

puts match #=> tjxmoewpdkyaihvrndfluwbzc

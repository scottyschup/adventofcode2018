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
  twos << code if has_n_repeated_chars(2, code)
  threes << code if has_n_repeated_chars(3, code)
end

puts twos.length * threes.length #=> 7872

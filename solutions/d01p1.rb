input = File.new('../inputs/01.txt').readlines()
freq = 0
input.each do |freq_delta|
  freq += freq_delta.to_i
end

puts freq #=> 518

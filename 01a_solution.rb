input = File.new('./01_input.txt').readlines()
freq = 0
input.each do |freq_delta|
  freq += freq_delta.to_i
end

puts freq

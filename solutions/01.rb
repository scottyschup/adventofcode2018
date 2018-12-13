# PART 1
input = File.new('../inputs/01.txt').readlines()
freq = 0
input.each do |freq_delta|
  freq += freq_delta.to_i
end

puts freq #=> 518

# PART 2
freq = 0
freqs = [true]
neg_freqs = []
done = false

until done
  input.each do |freq_delta|
    freq += freq_delta.to_i
    if freq < 0
      if neg_freqs[-freq]
        done = true
        break
      end
      neg_freqs[-freq] = true
    else
      if freqs[freq]
        done = true
        break
      end
      freqs[freq] = true
    end
  end
end

puts freq #=> 72889

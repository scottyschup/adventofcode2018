input = File.new('./01_input.txt').readlines()
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

puts freq

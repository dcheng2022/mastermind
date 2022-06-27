require 'pry-byebug'

def code_creator
  choices = %w[red blue green orange purple yellow blank]
  pattern = [choices.sample, choices.sample, choices.sample, choices.sample]
  p pattern
  pattern
end

def guess_getter
  choices = %w[red blue green orange purple yellow blank]
  puts 'Enter a guess.'
  loop do
    guess_array = gets.chomp.split
    return guess_array if guess_array.all? { |guess| choices.include?(guess) } && guess_array.length == 4

    puts 'Invalid guess! Please try again.'
  end
end

def guess_checker(guess_array, pattern)
  feedback = { color: 0, color_and_pos: 0 }
  pattern_copy = [].concat(pattern)
  matched_indices = []
  guess_array.each_with_index do |guess, idx|
    if guess == pattern_copy[idx]
      matched_indices << idx
      feedback[:color_and_pos] += 1
    end
  end
  matched_indices.each do |idx|
    guess_array[idx] = nil
    pattern_copy[idx] = nil
  end
  guess_array.compact!
  pattern_copy.compact!
  guess_array.uniq.each do |guess|
    pattern_color_amount = pattern_copy.reduce(0) { |sum, color| color == guess ? sum += 1 : sum }
    guess_color_amount = guess_array.reduce(0) { |sum, color| color == guess ? sum += 1 : sum }
    feedback[:color] += pattern_color_amount >= guess_color_amount ? guess_color_amount : pattern_color_amount
  end
  puts "Correct color and position: #{feedback[:color_and_pos]}"
  puts "Correct color only: #{feedback[:color]}"
end

guess_checker(guess_getter, code_creator)

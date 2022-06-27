require 'pry-byebug'

def code_creator
  choices = %w[red blue green orange purple yellow blank]
  pattern = Array.new(4).map { choices.sample }
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
  guess_array.each_with_index do |guess, idx|
    next unless guess == pattern_copy[idx]

    guess_array[idx] = nil
    pattern_copy[idx] = nil
    feedback[:color_and_pos] += 1
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
  feedback
end

def game
  puts 'Welcome to Mastermind! The goal of this game is to crack a code created by the codemaker. This code is four items long and draws from six different colors or a blank space, with repeats allowed. You will be given feedback on the accuracy of every guess. Break the code in 12 tries or lose!'
  puts 'The codebreaker has chosen a code.'
  code = code_creator
  turns = 1
  loop do
    feedback = guess_checker(guess_getter, code)
    if feedback[:color_and_pos] == 4
      puts "You cracked the code in #{turns} guesses. Hooray!"
      break
    elsif turns == 12
      puts "You were unable to break the code #{code} in 12 tries."
      break
    end
    turns += 1
  end
end

game

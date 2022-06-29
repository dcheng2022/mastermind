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
  guess_copy = [].concat(guess_array)
  pattern_copy = [].concat(pattern)
  guess_copy.each_with_index do |guess, idx|
    next unless guess == pattern_copy[idx]

    guess_copy[idx] = nil
    pattern_copy[idx] = nil
    feedback[:color_and_pos] += 1
  end
  guess_copy.compact!
  pattern_copy.compact!
  guess_copy.uniq.each do |guess|
    pattern_color_amount = pattern_copy.reduce(0) { |sum, color| color == guess ? sum += 1 : sum }
    guess_color_amount = guess_copy.reduce(0) { |sum, color| color == guess ? sum += 1 : sum }
    feedback[:color] += pattern_color_amount >= guess_color_amount ? guess_color_amount : pattern_color_amount
  end
  puts "Correct color and position: #{feedback[:color_and_pos]}"
  puts "Correct color only: #{feedback[:color]}"
  feedback
end

def computer_guesser(pattern)
  choices = %w[red blue yellow green purple orange blank]
  learning_array = []
  permutation_array = []
  lock_info = { index: [] }
  total_matches = 0
  choices.shuffle.each_with_index do |color, idx|
    learning_array.concat(Array.new(4 - total_matches, color))
    rotated_learning_array = learning_array.rotate(idx)
    feedback = guess_checker(rotated_learning_array, pattern)
    total_matches = feedback[:color_and_pos] + feedback[:color]
    if learning_array.uniq.length == 2 && total_matches == feedback[:color_and_pos]
      lock_info[:color] = learning_array.uniq.reject { |e| e == color }.join
      rotated_learning_array.each_with_index { |e, index| lock_info[:index] << index if e == lock_info[:color] }
    end
    learning_array.pop while learning_array.length > total_matches
    next unless total_matches == 4
    return true if feedback[:color_and_pos] == 4

    break
  end
  learning_array.permutation { |perm| permutation_array << perm }
  permutation_array.uniq.each do |uniq_perm|
    next unless lock_info[:index].empty? || permutation_match_checker(lock_info, uniq_perm)

    feedback = guess_checker(uniq_perm, pattern)
    break if feedback[:color_and_pos] == 4
  end
end

def permutation_match_checker(lock_info, perm)
  lock_info[:index].each { |idx| return false unless perm[idx] == lock_info[:color] }
  true
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

#game

computer_guesser(code_creator)

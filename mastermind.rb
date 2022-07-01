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
  choices = %w[red blue green orange purple yellow blank]
  learning_array = []
  lock_info = { index: [], color: [] }
  purge_hash = { index: [], color: [] }
  total_matches = 0
  choices.shuffle.each_with_index do |color, idx|
    learning_array.concat(Array.new(4 - total_matches, color))
    rotated_learning_array = learning_array.rotate(idx)
    feedback = guess_checker(rotated_learning_array, pattern)
    total_matches = feedback[:color_and_pos] + feedback[:color]
    if learning_array.uniq.length >= 2 && total_matches == feedback[:color_and_pos]
      rotated_learning_array.each_with_index do |e, e_idx|
        next if e == color

        lock_info[:color] << e
        lock_info[:index] << e_idx
      end
    end
    learning_array.pop while learning_array.length > total_matches
    next unless total_matches == 4

    purge_hash_updater(purge_hash, rotated_learning_array) if feedback[:color] == 4
    return true if feedback[:color_and_pos] == 4

    break
  end
  permutation_creator(purge_hash, lock_info, learning_array, pattern)
end

def permutation_creator(purge_hash, lock_info, learning_array, pattern)
  permutation_array = []
  learning_array.permutation { |perm| permutation_array << perm }
  permutation_array.uniq.each do |uniq_perm|
    next unless lock_info[:index].empty? || permutation_match_checker(lock_info, uniq_perm)
    next unless purge_hash[:index].empty? || permutation_purger(purge_hash, uniq_perm)

    feedback = guess_checker(uniq_perm, pattern)
    break if feedback[:color_and_pos] == 4
    next unless feedback[:color] == 4

    purge_hash_updater(purge_hash, uniq_perm)
  end
end

def purge_hash_updater(purge_hash, guess_array)
  guess_array.each_with_index do |color, idx|
    purge_hash[:color] << color
    purge_hash[:index] << idx
  end
  purge_hash
end

def permutation_purger(purge_hash, perm)
  purge_hash[:color].each_with_index { |color, idx| return false if perm[purge_hash[:index][idx]] == color }
  true
end

def permutation_match_checker(lock_info, perm)
  lock_info[:index].each_with_index { |perm_idx, color_idx| return false unless perm[perm_idx] == lock_info[:color][color_idx] }
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

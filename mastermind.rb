require 'pry-byebug'

class Player
  @@choices = %w[red blue green orange purple yellow blank]
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def enter_input
    loop do
      input = gets.chomp.split
      return input if input.all? { |color| @@choices.include?(color) } && input.length == 4

      puts 'Invalid input. Please try again.'
    end
  end
end

class Codemaker < Player
  def create_code
    if name == 'Computer'
      self.pattern = Array.new(4).map { @@choices.sample }
    else
      puts "Enter your code composed of the following: #{@@choices.join(' ')}"
      self.pattern = enter_input
    end
  end

  def check_guess(guess_array)
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

  private

  attr_accessor :pattern
end

class Codebreaker < Player
  @@tries = 0

  def guess(codemaker)
    puts "Enter a guess composed of the following: #{@@choices.join(' ')}"
    unless name == 'Computer'
      loop do
        @@tries += 1
        feedback = codemaker.check_guess(enter_input)
        return @@tries if feedback[:color_and_pos] == 4
      end
    end

    learning_array = []
    lock_info = { index: [], color: [] }
    purge_hash = { index: [], color: [] }
    total_matches = 0
    @@choices.shuffle.each_with_index do |color, idx|
      @@tries += 1
      learning_array.concat(Array.new(4 - total_matches, color))
      rotated_learning_array = learning_array.rotate(idx)
      p rotated_learning_array.join(' ')
      feedback = codemaker.check_guess(rotated_learning_array)
      total_matches = feedback[:color_and_pos] + feedback[:color]
      if learning_array.uniq.length >= 2 && total_matches == feedback[:color_and_pos]
        hash_updater(lock_info, rotated_learning_array, color)
      end
      learning_array.pop while learning_array.length > total_matches
      next unless total_matches == 4

      hash_updater(purge_hash, rotated_learning_array) if feedback[:color] == 4
      return @@tries if feedback[:color_and_pos] == 4

      break
    end
    permutation_creator(purge_hash, lock_info, learning_array, codemaker)
  end

  def permutation_creator(purge_hash, lock_info, learning_array, codemaker)
    permutation_array = []
    learning_array.permutation { |perm| permutation_array << perm }
    permutation_array.uniq.each do |uniq_perm|
      next unless permutation_validator(lock_info, purge_hash, uniq_perm)

      @@tries += 1
      p uniq_perm.join(' ')
      feedback = codemaker.check_guess(uniq_perm)
      return @@tries if feedback[:color_and_pos] == 4
      next unless feedback[:color] == 4

      hash_updater(purge_hash, uniq_perm)
    end
  end

  def hash_updater(hash, guess_array, ignore = nil)
    guess_array.each_with_index do |color, idx|
      next if color == ignore

      hash[:color] << color
      hash[:index] << idx
    end
  end

  def permutation_validator(lock_info, purge_hash, perm)
    return true if lock_info[:index].empty? && purge_hash[:index].empty?

    purge_hash[:color].each_with_index { |color, idx| return false if perm[purge_hash[:index][idx]] == color } unless purge_hash[:index].empty?
    lock_info[:color].each_with_index { |color, idx| return false unless perm[lock_info[:index][idx]] == color } unless lock_info[:index].empty?
    true
  end
end

def select_role
  loop do
    input = gets.chomp.downcase
    return input if %w[codemaker codebreaker].include?(input)

    puts 'Invalid input. Please only enter the role you would like to play.'
  end
end

def game
  puts 'Welcome to Mastermind! This is a code-breaking game for two players, the codemaker and codebreaker. The codemaker chooses a pattern of four colors or blanks, which may or may not repeat. The codebreaker tries to guess the pattern, both in order and color, within 12 turns. The codemaker provides feedback on the number of close matches and exact matches each turn. Guesses are made until the codebreaker guesses correctly or runs out of turns.'
  puts 'Would you like to play as the codemaker or codebreaker?'
  case select_role
  when 'codebreaker'
    codebreaker = Codebreaker.new('Player')
    codemaker = Codemaker.new('Computer')
  when 'codemaker'
    codebreaker = Codebreaker.new('Computer')
    codemaker = Codemaker.new('Player')
  end
  codemaker.create_code
  tries = codebreaker.guess(codemaker)
  message = tries > 12 ? "#{codebreaker.name} failed to solve the code within 12 tries... it took them #{tries} tries to obtain the code." : "#{codebreaker.name} successfully solved the code in #{tries} tries!"
  puts message
end

game

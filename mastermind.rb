require 'pry-byebug'

def create_code
  choices = %w[red blue green orange purple yellow blank]
  pattern = [choices.sample, choices.sample, choices.sample, choices.sample]
  p pattern
end

def guess_getter
  choices = %w[red blue green orange purple yellow blank]
  loop do
    puts 'Enter a guess.'
    guess_array = gets.chomp.split
    return guess_array if guess_array.all? { |guess| choices.include?(guess) } && guess_array.length == 4
  end
end

guess_getter

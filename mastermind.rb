require 'pry-byebug'

def create_code
  choices = %w[red blue green orange purple yellow blank]
  pattern = [choices.sample, choices.sample, choices.sample, choices.sample]
  p pattern
end

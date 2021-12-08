# frozen_string_literal: true

# Lanternfish (https://adventofcode.com/2021/day/6)
class Six
  def initialize(path)
    @input_path = path
  end

  def self.simulate(path, duration)
    new(path).simulate(duration)
  end

  def simulate(duration)
    counts = lanternfishes.each_with_object(Array.new(9, 0)) do |counter, memo|
      memo[counter] += 1
    end
    duration.times do
      counts.rotate!
      counts[6] += counts[8]
    end
    counts.reduce(:+)
  end

  private

  attr_reader :input_path

  def lanternfishes
    @lanternfishes ||= File.readlines(input_path).join(',').split(',').map(&:to_i)
  end
end

puts Six.simulate('six_example.txt', 18)
puts Six.simulate('six_example.txt', 80)
puts Six.simulate('six_example.txt', 256)
puts Six.simulate('six.txt', 80)
puts Six.simulate('six.txt', 256)

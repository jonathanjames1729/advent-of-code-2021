# frozen_string_literal: true

# The Treachery of Whales (https://adventofcode.com/2021/day/7)
class Seven
  def initialize(path)
    @input_path = path
  end

  def self.align_crabs(path)
    new(path).align_crabs
  end

  def self.align_crabs_corrected(path)
    new(path).align_crabs_corrected
  end

  def align_crabs
    cost = cost_at_min_position
    best_cost = cost
    ((min_position + 1)..max_position).each do |try|
      positions.each do |position, count|
        cost += (position < try ? count : -count)
      end

      best_cost = cost if cost < best_cost
    end
    best_cost
  end

  def align_crabs_corrected
    cost = cost_at_min_position_corrected
    best_cost = cost
    ((min_position + 1)..max_position).each do |try|
      positions.each do |position, count|
        cost += (position < try ? (count * (try - position)) : -(count * (position - try + 1)))
      end

      best_cost = cost if cost < best_cost
    end
    best_cost
  end

  private

  attr_reader :input_path

  def positions
    @positions ||= File.readlines(input_path).join(',').split(',').map(&:to_i).each_with_object({}) do |position, memo|
      memo[position] ||= 0
      memo[position] += 1
    end
  end

  def min_position
    @min_position ||= positions.keys.min
  end

  def max_position
    @max_position ||= positions.keys.max
  end

  def cost_at_min_position
    positions.reduce(0) { |memo, (position, count)| memo + ((position - min_position) * count) }
  end

  def cost_at_min_position_corrected
    positions.reduce(0) do |memo, (position, count)|
      memo + ((position - min_position) * (position - min_position + 1) * count / 2)
    end
  end
end

puts Seven.align_crabs('seven_example.txt')
puts Seven.align_crabs('seven.txt')
puts Seven.align_crabs_corrected('seven_example.txt')
puts Seven.align_crabs_corrected('seven.txt')

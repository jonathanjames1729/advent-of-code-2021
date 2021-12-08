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
    min_position = positions.keys.min
    max_position = positions.keys.max
    cost = positions.reduce(0) { |memo, (position, count)| memo + ((position - min_position) * count) }
    best_cost = cost
    best_position = min_position
    ((min_position + 1)..max_position).each do |try|
      positions.each do |position, count|
        if position < try
          cost += count
        else
          cost -= count
        end
      end
      if cost < best_cost
        best_cost = cost
        best_position = try
      end
    end
    puts "#{best_cost} at #{best_position}"
    best_cost
  end

  def align_crabs_corrected
    min_position = positions.keys.min
    max_position = positions.keys.max
    cost = positions.reduce(0) do |memo, (position, count)|
      memo + ((position - min_position) * (position - min_position + 1) * count / 2)
    end
    best_cost = cost
    best_position = min_position
    ((min_position + 1)..max_position).each do |try|
      positions.each do |position, count|
        if position < try
          cost += (count * (try - position))
        else
          cost -= (count * (position - try + 1))
        end
      end
      if cost < best_cost
        best_cost = cost
        best_position = try
      end
    end
    puts "#{best_cost} at #{best_position}"
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
end

puts Seven.align_crabs('seven_example.txt')
puts Seven.align_crabs('seven.txt')
puts Seven.align_crabs_corrected('seven_example.txt')
puts Seven.align_crabs_corrected('seven.txt')

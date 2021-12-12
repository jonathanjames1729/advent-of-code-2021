# frozen_string_literal: true

# Passage Pathing (https://adventofcode.com/2021/day/12)
class Twelve
  def initialize(path)
    @input_path = path
    @paths = []
  end

  def self.count_paths(path)
    new(path).count_paths(false)
  end

  def self.count_paths_corrected(path)
    new(path).count_paths(true)
  end

  def count_paths(corrected)
    travel([network], corrected)
    paths.count
  end

  private

  attr_reader :input_path, :paths

  def network
    @network ||= load
  end

  def load
    lookup = {}
    File.readlines(input_path).each do |line|
      name_one, _, name_two = line.strip.partition('-')
      lookup[name_one] ||= create_cave(name_one)
      lookup[name_two] ||= create_cave(name_two)
      join_caves(lookup[name_one], lookup[name_two])
    end
    lookup['start']
  end

  def create_cave(name)
    {
      name: name,
      small: (name == name.downcase),
      links: []
    }
  end

  def join_caves(cave_one, cave_two)
    cave_one[:links].append(cave_two)
    cave_two[:links].append(cave_one)
  end

  def travel(current_path, revisit_small)
    current_path.last[:links].each do |linked_cave|
      if linked_cave[:name] == 'end'
        add_path(current_path)
      elsif linked_cave[:small] && current_path.include?(linked_cave)
        next unless revisit_small && (linked_cave[:name] != 'start')

        travel_to(current_path, linked_cave, false)
      else
        travel_to(current_path, linked_cave, revisit_small)
      end
    end
  end

  def add_path(current_path)
    path = current_path.map { |cave| cave[:name] }.append('end')
    paths.append(path.join(','))
  end

  def travel_to(current_path, cave, revisit_small)
    travel(Array.new(current_path).append(cave), revisit_small)
  end
end

puts Twelve.count_paths('twelve_example_one.txt')
puts Twelve.count_paths('twelve_example_two.txt')
puts Twelve.count_paths('twelve_example_three.txt')
puts Twelve.count_paths('twelve.txt')

puts Twelve.count_paths_corrected('twelve_example_one.txt')
puts Twelve.count_paths_corrected('twelve_example_two.txt')
puts Twelve.count_paths_corrected('twelve_example_three.txt')
puts Twelve.count_paths_corrected('twelve.txt')

# frozen_string_literal: true

# Dumbo Octopus (https://adventofcode.com/2021/day/11)
class Eleven
  def initialize(path)
    @input_path = path
  end

  def self.flash_count(path)
    new(path).flash_count
  end

  def self.flashes_synchronised(path)
    new(path).flashes_synchronised
  end

  def flash_count
    (0...100).reduce(0) do |total, _|
      total + step
    end
  end

  def flashes_synchronised
    count = 1
    count += 1 until step == size
    count
  end

  private

  attr_reader :input_path

  def energy
    @energy ||= File.readlines(input_path).map do |line|
      line.strip.chars.map(&:to_i)
    end
  end

  def x_max
    energy[0].count - 1
  end

  def y_max
    energy.count - 1
  end

  def size
    energy.count * energy[0].count
  end

  def increase_all_energy
    energy.each do |line|
      line.map! { |level| level + 1 }
    end
  end

  def find_flashes(step_flashes)
    (0..y_max).each_with_object([]) do |y, flashes|
      (0..x_max).each do |x|
        flashes.append([x, y]) unless step_flashes.include?([x, y]) || (energy[y][x] <= 9)
      end
    end
  end

  def side(position, max)
    yield (position - 1) if position.positive?
    yield position
    yield (position + 1) if position < max
  end

  def increase_adjacent_energy(flashes)
    flashes.each do |x, y|
      side(y, y_max) do |yy|
        side(x, x_max) do |xx|
          energy[yy][xx] += 1
        end
      end
    end
  end

  def step
    increase_all_energy
    step_flashes = []
    loop do
      next_flashes = find_flashes(step_flashes)
      break if next_flashes.empty?

      increase_adjacent_energy(next_flashes)

      step_flashes.concat(next_flashes)
    end

    step_flashes.each { |x, y| energy[y][x] = 0 }

    step_flashes.count
  end
end

puts Eleven.flash_count('eleven_example.txt')
puts Eleven.flash_count('eleven.txt')

puts Eleven.flashes_synchronised('eleven_example.txt')
puts Eleven.flashes_synchronised('eleven.txt')

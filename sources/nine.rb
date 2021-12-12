# frozen_string_literal: true

# Smoke Basin (https://adventofcode.com/2021/day/9
class Nine
  def initialize(path)
    @input_path = path
  end

  def self.risks(path)
    new(path).risks
  end

  def self.basins(path)
    new(path).basins
  end

  def risks
    low_points.reduce(0) { |total, (x, y)| total + height_map[y][x] + 1 }
  end

  def basins
    low_points.map do |x, y|
      basin([], x, y).count
    end.sort.last(3).reduce(&:*)
  end

  private

  attr_reader :input_path

  def height_map
    @height_map ||= File.readlines(input_path).map { |line| line.strip.chars.map(&:to_i) }
  end

  def x_max
    @x_max ||= (height_map[0].count - 1)
  end

  def y_max
    @y_max ||= (height_map.count - 1)
  end

  def adjacent(x_position, y_position)
    yield [x_position - 1, y_position] if x_position.positive?
    yield [x_position, y_position - 1] if y_position.positive?
    yield [x_position + 1, y_position] if x_position < x_max
    yield [x_position, y_position + 1] if y_position < y_max
  end

  def low?(x_position, y_position)
    height = height_map[y_position][x_position]
    adjacent(x_position, y_position) { |x, y| return false if height_map[y][x] <= height }

    true
  end

  def low_points
    (0..y_max).each_with_object([]) do |y, lows|
      (0..x_max).each do |x|
        lows.append([x, y]) if low?(x, y)
      end
    end
  end

  def basin(points, x_position, y_position)
    height = height_map[y_position][x_position]
    return points if height == 9

    points.append([x_position, y_position])
    adjacent(x_position, y_position) do |x, y|
      basin(points, x, y) unless points.include?([x, y])
    end

    points
  end
end

puts Nine.risks('nine_example.txt')
puts Nine.risks('nine.txt')
puts Nine.basins('nine_example.txt')
puts Nine.basins('nine.txt')

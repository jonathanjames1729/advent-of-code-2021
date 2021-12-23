# frozen_string_literal: true

require 'pry'

# Trench Map (https://adventofcode.com/2021/day/20)
class Twenty
  def initialize(path)
    @input_path = path
  end

  def self.enhance(path, repeats)
    new(path).enhance(repeats)
  end

  def enhance(repeats)
    load
    result = image
    repeats.times { result = result.enhanced(enhancement) }
    result.count
  end

  private

  attr_reader :input_path, :image, :enhancement

  def load
    lines = File.readlines(input_path).map do |line|
      line.strip.chars.map { |char| char == '#' ? 1 : 0 }
    end

    @enhancement = lines.shift
    raise 'Error' unless lines.shift.empty?

    @image = Image.new(lines, 0)
  end
end

# Scanner Image
class Image
  attr_reader :width, :height, :infinity

  def initialize(lines, infinity)
    @width = lines[0].count
    @height = lines.count
    @rows = lines.map(&:dup)
    @infinity = infinity
  end

  def pixel(x_position, y_position)
    return infinity unless (0...width).include?(x_position) && (0...height).include?(y_position)

    rows[y_position][x_position]
  end

  def enhanced(enhancement)
    enhanced_rows = (-1..height).map do |y|
      (-1..width).map do |x|
        enhanced_pixel(x, y, enhancement)
      end
    end
    self.class.new(enhanced_rows, enhanced_infinity(enhancement))
  end

  def count
    raise 'Infinite' unless infinity.zero?

    rows.reduce(0) { |sum, row| sum + row.sum }
  end

  private

  attr_reader :rows

  def neighbourhood(x_position, y_position)
    (y_position - 1..y_position + 1).each_with_object([]) do |y, nbhd|
      (x_position - 1..x_position + 1).each do |x|
        nbhd.append(pixel(x, y))
      end
    end
  end

  def neighbourhood_value(x_position, y_position)
    neighbourhood(x_position, y_position).reduce(0) { |value, pixel| value * 2 + pixel }
  end

  def enhanced_pixel(x_position, y_position, enhancement)
    enhancement[neighbourhood_value(x_position, y_position)]
  end

  def enhanced_infinity(enhancement)
    infinity.zero? ? enhancement.first : enhancement.last
  end
end

puts Twenty.enhance('twenty_example.txt', 2)
puts Twenty.enhance('twenty.txt', 2)

puts Twenty.enhance('twenty_example.txt', 50)
puts Twenty.enhance('twenty.txt', 50)

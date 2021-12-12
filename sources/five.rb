# frozen_string_literal: true

# Hydrothermal Venture (https://adventofcode.com/2021/day/5)
class Five
  def initialize(path)
    @input_path = path
  end

  def self.horizontal_and_vertical_overlaps(path)
    new(path).horizontal_and_vertical_overlaps
  end

  def self.all_overlaps(path)
    new(path).all_overlaps
  end

  def horizontal_and_vertical_overlaps
    self.class.overlaps(horizontal_and_vertical_lines)
  end

  def all_overlaps
    self.class.overlaps(all_lines)
  end

  def self.overlaps(lines)
    overlaps = []
    lines.each_with_index do |line1, index1|
      lines.each_with_index do |line2, index2|
        if index1 > index2
          (line1 & line2).each { |point| overlaps.append(point) unless overlaps.include?(point) }
        end
      end
    end
    overlaps.count
  end

  private

  attr_reader :input_path

  def lines
    @lines ||= File.readlines(input_path).map do |line|
      match = /(\d+),(\d+) -> (\d+),(\d+)/.match(line)
      [match.values_at(1, 2).map(&:to_i), match.values_at(3, 4).map(&:to_i)]
    end
  end

  def interval(one, two, &blk)
    interval = one < two ? (one..two) : (two..one)
    interval.map(&blk)
  end

  def horizontal_and_vertical_lines
    @horizontal_and_vertical_lines ||= lines.map do |(x1, y1), (x2, y2)|
      if x1 == x2
        interval(y1, y2) { |y| [x1, y] }
      elsif y1 == y2
        interval(x1, x2) { |x| [x, y1] }
      end
    end.compact
  end

  def all_lines
    @all_lines ||= lines.map do |(x1, y1), (x2, y2)|
      x_step = (x2 <=> x1)
      y_step = (y2 <=> y1)
      line = [[x1, y1]]
      loop do
        x, y = line.last
        break line if (x == x2) && (y == y2)

        line.append([x + x_step, y + y_step])
      end
    end
  end
end

puts Five.horizontal_and_vertical_overlaps('five_example.txt')
puts Five.horizontal_and_vertical_overlaps('five.txt')

puts Five.all_overlaps('five_example.txt')
puts Five.all_overlaps('five.txt')

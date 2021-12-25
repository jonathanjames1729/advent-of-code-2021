# frozen_string_literal: true

require 'pry'

# Transparent Origami (https://adventofcode.com/2021/day/13)
class Thirteen
  def initialize(path)
    @input_path = path
    @points = []
    @folds = []
  end

  def self.perform_first_fold(path)
    new(path).perform_first_fold
  end

  def self.perform_all_folds(path)
    new(path).perform_all_folds
  end

  def perform_first_fold
    load
    perform_fold(folds.first)
    points.count
  end

  def perform_all_folds
    load
    folds.each do |fold|
      perform_fold(fold)
    end
    render
  end

  private

  attr_reader :input_path, :points, :folds

  def load
    marker = false
    File.readlines(input_path).each do |line|
      if line.strip!.empty?
        marker = true
      elsif marker
        load_fold(line)
      else
        load_point(line)
      end
    end
  end

  def load_point(line)
    points.append(line.split(',').map(&:to_i))
  end

  def load_fold(line)
    match = /^fold along (x|y)=(\d+)$/.match(line)
    folds.append([match[1].to_sym, match[2].to_i])
  end

  def perform_fold(fold)
    case fold[0]
    when :x
      perform_vertical_fold(fold[1])
    when :y
      perform_horizontal_fold(fold[1])
    end
  end

  def perform_vertical_fold(x_position)
    points.map! do |point|
      x = point[0]
      if x > x_position
        [(2 * x_position) - x, point[1]]
      else
        point
      end
    end.uniq!
  end

  def perform_horizontal_fold(y_position)
    points.map! do |point|
      y = point[1]
      if y > y_position
        [point[0], (2 * y_position) - y]
      else
        point
      end
    end.uniq!
  end

  def max_x
    points.reduce(0) { |max, (x, _)| x > max ? x : max }
  end

  def max_y
    points.reduce(0) { |max, (_, y)| y > max ? y : max }
  end

  def render
    rendered = points.each_with_object(Array.new(max_y + 1) { Array.new(max_x + 1, ' ') }) do |(x, y), grid|
      grid[y][x] = '#'
    end
    rendered.map(&:join).join("\n")
  end
end

puts Thirteen.perform_first_fold('thirteen_example.txt')
puts Thirteen.perform_first_fold('thirteen.txt')
puts
puts Thirteen.perform_all_folds('thirteen_example.txt')
puts
puts Thirteen.perform_all_folds('thirteen.txt')
puts

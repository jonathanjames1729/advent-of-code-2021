# frozen_string_literal: true

# Sea Cucumber (https://adventofcode.com/2021/day/25)
class TwentyFive
  def initialize(path)
    @input_path = path
  end

  def self.stop_moving(path)
    new(path).stop_moving
  end

  def stop_moving
    (1..).each do |count|
      no_east = perform_east_moves
      no_south = perform_south_moves
      break count if no_south && no_east
    end
  end

  private

  attr_reader :input_path

  def rows
    @rows ||= File.readlines(input_path).map do |line|
      line.strip.chars
    end
  end

  def width
    @width ||= rows.first.count
  end

  def height
    @height ||= rows.count
  end

  def east
    @east ||= find('>')
  end

  def south
    @south ||= find('v')
  end

  def find(char)
    result = []
    rows.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        result.append([x, y]) if cell == char
      end
    end
    result
  end

  def east_moves
    east.map do |x, y|
      x = (x + 1) % width
      rows[y][x] == '.' ? [x, y] : nil
    end
  end

  def south_moves
    south.map do |x, y|
      y = (y + 1) % height
      rows[y][x] == '.' ? [x, y] : nil
    end
  end

  def set_point(coord, value)
    rows[coord[1]][coord[0]] = value
  end

  def perform_moves(positions, moves, char)
    return true unless moves.any?

    moves.each_with_index do |position, index|
      next if position.nil?

      previous_position = positions[index]
      set_point(previous_position, '.')
      set_point(position, char)
      positions[index] = position
    end
    false
  end

  def perform_east_moves
    perform_moves(east, east_moves, '>')
  end

  def perform_south_moves
    perform_moves(south, south_moves, 'v')
  end
end

puts TwentyFive.stop_moving('twenty_five_example.txt')
puts TwentyFive.stop_moving('twenty_five.txt')

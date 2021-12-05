# frozen_string_literal: true

require 'pry'

# Giant Squid (https://adventofcode.com/2021/day/4)
class Four
  def initialize(path)
    @input_path = path
    @draw = []
    @boards = []
    @scores = []
  end

  def self.play(path)
    new(path).play
  end

  def play
    load
    draw.each do |number|
      to_remove = []
      boards.each_with_index { |board, index| to_remove.append(index) if board.play(number) }
      to_remove.reverse_each { |index| scores.append(boards.delete_at(index).score * number) }
    end
    scores
  end

  private

  attr_reader :input_path, :draw, :boards, :scores

  def load
    File.open(input_path) do |file|
      load_draw(file)
      load_boards(file)
    end
  end

  def load_draw(file)
    @draw = file.readline.strip.split(',').map(&:to_i)
  end

  def load_boards(file)
    loop do
      file.readline
      board = Board.new(file)
      boards.append(board)
    rescue EOFError
      break
    end
  end
end

# Bingo Board
class Board
  def initialize(file)
    @numbers = []
    @marked = Array.new(5) { Array.new(5, false) }
    5.times { numbers.append(file.readline.strip.split.map(&:to_i)) }
  end

  def play(number)
    coord = mark(number)
    return false if coord.nil?

    x, y = coord
    check_row(y) || check_column(x)
  end

  def score
    total = 0
    numbers.each_with_index do |row, y|
      row.each_with_index do |number, x|
        total += number unless marked[y][x]
      end
    end
    total
  end

  private

  attr_reader :numbers, :marked

  def mark(number)
    numbers.each_with_index do |row, y|
      x = row.find_index(number)
      unless x.nil?
        marked[y][x] = true
        return [x, y]
      end
    end
    nil
  end

  def check_row(y_coord)
    marked[y_coord].all?
  end

  def check_column(x_coord)
    marked.all? { |row| row[x_coord] }
  end
end

scores_example = Four.play('four_example.txt')
scores = Four.play('four.txt')

puts scores_example.first
puts scores.first

puts scores_example.last
puts scores.last

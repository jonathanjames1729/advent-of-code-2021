# frozen_string_literal: true

# Dirac Dice (https://adventofcode.com/2021/day/21)
class TwentyOne
  def initialize(path)
    @input_path = path
    @rolls = 0
    @scores = { 1 => 0, 2 => 0 }

    @wins = { 1 => 0, 2 => 0 }
    @data = []
    @weights = Hash.new(0)
  end

  def self.play(path)
    new(path).play
  end

  def self.play_all(path)
    new(path).play_all
  end

  def play
    turn = 0
    loop do
      turn += 1
      player = turn.even? ? 2 : 1
      move = three_rolls
      break if do_move(player, move) >= 1000
    end
    scores[turn.even? ? 1 : 2] * rolls
  end

  def play_all
    init_weights
    (0..1).each { |i| data[i] = { position: positions[i + 1], score: 0 } }
    take_turn(1, 1)
    wins.values.max
  end

  private

  attr_reader :input_path, :rolls, :scores, :wins, :data, :weights

  def positions
    @positions ||= File.readlines(input_path).each_with_object({}) do |line, pos|
      match = /^Player (1|2) starting position: (10|[1-9])$/.match(line.strip)
      pos[match[1].to_i] = match[2].to_i
    end
  end

  def roll
    @rolls += 1
    result = rolls % 100
    result.zero? ? 100 : result
  end

  def three_rolls
    (1..3).reduce(0) { |sum, _| sum + roll }
  end

  def do_move(player, move)
    result = do_move_inner(positions[player], scores[player], move)
    positions[player] = result[:position]
    scores[player] = result[:score]
  end

  def do_move_inner(position, score, move)
    position = (position + move) % 10
    position = 10 if position.zero?
    { position: position, score: (score + position) }
  end

  def init_weights
    (1..3).each do |i|
      (1..3).each do |j|
        (1..3).each do |k|
          weights[i + j + k] += 1
        end
      end
    end
  end

  def take_turn(turn, weight)
    weights.each { |move, move_weight| do_move_outer(turn, move, weight * move_weight) }
  end

  def do_move_outer(turn, move, weight)
    previous = data[turn - 1]
    result = do_move_inner(previous[:position], previous[:score], move)
    if result[:score] >= 21
      player = turn.even? ? 2 : 1
      wins[player] += weight
    else
      data[turn + 1] = result
      take_turn(turn + 1, weight)
    end
  end
end

puts TwentyOne.play('twenty_one_example.txt')
puts TwentyOne.play('twenty_one.txt')

puts TwentyOne.play_all('twenty_one_example.txt')
puts TwentyOne.play_all('twenty_one.txt')

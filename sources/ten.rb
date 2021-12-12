# frozen_string_literal: true

# Syntax Scoring (https://adventofcode.com/2021/day/10)
class Ten
  CHUNK_MARKERS = { '(' => ')', '[' => ']', '{' => '}', '<' => '>' }.freeze
  SCORE_CORRUPTED = { ')' => 3, ']' => 57, '}' => 1197, '>' => 25_137 }.freeze
  SCORE_AUTOCOMPLETE = { ')' => 1, ']' => 2, '}' => 3, '>' => 4 }.freeze

  def initialize(path)
    @input_path = path
  end

  def self.score_corrupted(path)
    new(path).score_corrupted
  end

  def self.score_autocomplete(path)
    new(path).score_autocomplete
  end

  def score_corrupted
    lines.reduce(0) do |total, line|
      result = check_line(line)
      if result[0] == :corrupted
        total + SCORE_CORRUPTED[result[1]]
      else
        total
      end
    end
  end

  def score_autocomplete
    scores = lines.map do |line|
      result = check_line(line)
      next unless result[0] == :incomplete

      result[1].reverse.reduce(0) do |total, char|
        (total * 5) + SCORE_AUTOCOMPLETE[char]
      end
    end.compact.sort
    scores[scores.count / 2]
  end

  private

  attr_reader :input_path

  def lines
    @lines ||= File.readlines(input_path).map(&:strip)
  end

  def check_line(line)
    opened = []
    line.each_char do |char|
      if CHUNK_MARKERS.key?(char)
        opened.append(CHUNK_MARKERS[char])
      elsif CHUNK_MARKERS.value?(char)
        marker = opened.pop
        return [:corrupted, char] if char != marker
      end
    end
    opened.empty? ? [:valid] : [:incomplete, opened]
  end
end

puts Ten.score_corrupted('ten_example.txt')
puts Ten.score_corrupted('ten.txt')

puts Ten.score_autocomplete('ten_example.txt')
puts Ten.score_autocomplete('ten.txt')

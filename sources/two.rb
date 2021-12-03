# frozen_string_literal: true

class Two
  attr_reader :depth, :horizontal

  def initialize(path)
    @input_path = path
    @depth = 0
    @horizontal = 0
  end

  def self.follow(path)
    new(path).follow
  end

  def self.follow_corrected(path)
    new(path).follow_corrected
  end

  def follow
    @course = load
    process
    depth * horizontal
  end

  def follow_corrected
    @course = load
    process_corrected
    depth * horizontal
  end

  private

  attr_reader :input_path, :course

  def load
    File.readlines(input_path).map do |line|
      tuple = line.split
      {
        command: tuple[0].to_sym,
        magnitude: tuple[1].to_i
      }
    end
  end

  def process
    course.each do |step|
      case step[:command]
      when :forward
        @horizontal += step[:magnitude]
      when :down
        @depth += step[:magnitude]
      when :up
        @depth -= step[:magnitude]
      end
    end
  end

  def process_corrected
    aim = 0
    course.each do |step|
      case step[:command]
      when :forward
        @horizontal += step[:magnitude]
        @depth += (step[:magnitude] * aim)
      when :down
        aim += step[:magnitude]
      when :up
        aim -= step[:magnitude]
      end
    end
  end
end

puts Two.follow('two.txt')
puts Two.follow_corrected('two.txt')

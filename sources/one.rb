# frozen_string_literal: true

class One
  def initialize(path, size)
    @input_path = path
    @window_size = size
  end

  def self.count_increases(path, window_size=1)
    new(path, window_size).count_increases
  end

  def count_increases
    @measurements = load
    @windowed = sliding_window
    count
  end

  private

  attr_reader :input_path, :window_size, :measurements, :windowed

  def load
    File.readlines(input_path).map { |line| line.to_i }
  end

  def sliding_window
    process = []
    measurements.filter_map do |measurement|
      process.map! { |element| element + measurement }.append(measurement)
      process.count < window_size ? nil : process.shift
    end
  end

  def count
    windowed.reduce([0, nil]) do |(increasing_count, previous_sum), sum|
      if previous_sum.nil? || sum <= previous_sum
        [increasing_count, sum]
      else 
        [increasing_count + 1, sum]
      end
    end[0]
  end
end

puts One.count_increases('one.txt')
puts One.count_increases('one.txt', 3)

# frozen_string_literal: true

class Three
  attr_reader :epsilon_rate, :gamma_rate

  def initialize(path)
    @input_path = path
    @epsilon_rate = 0
    @gamma_rate = 0
  end

  def self.power_consumption(path)
    new(path).power_consumption
  end

  def self.life_support_rating(path)
    new(path).oxygen_generator_rating * new(path).co2_scrubber_rating
  end

  def power_consumption
    @report = load
    calculate_rates
    gamma_rate * epsilon_rate
  end

  def oxygen_generator_rating
    @report = load
    bit_index = 0
    loop do
      length = report.count
      break if length == 1

      most_common_value = (2 * bit_counts[bit_index]) >= length ? 1 : 0
      @report.filter! { |row| row[bit_index] == most_common_value }
      bit_index += 1
    end
    report[0].join('').to_i(2)
  end

  def co2_scrubber_rating
    @report = load
    bit_index = 0
    loop do
      length = report.count
      break if length == 1

      least_common_value = (2 * bit_counts[bit_index]) >= length ? 0 : 1
      @report.filter! { |row| row[bit_index] == least_common_value }
      bit_index += 1
    end
    report[0].join('').to_i(2)
  end

  private

  attr_reader :input_path, :report

  def load
    File.readlines(input_path).map do |line|
      line.strip.split('').map(&:to_i)
    end
  end

  def bit_counts
    result = []
    Array.new(report[0].count, 0).zip(*report) { |column| result.append(column.reduce(:+)) }
    result
  end

  def calculate_rates
    length = report.count
    counts = bit_counts
    @gamma_rate = counts.map { |count| count > (length - count) ? 1 : 0 }.join('').to_i(2)
    @epsilon_rate = counts.map { |count| count < (length - count) ? 1 : 0 }.join('').to_i(2)
  end
end

puts Three.power_consumption('three.txt')
puts Three.life_support_rating('three.txt')

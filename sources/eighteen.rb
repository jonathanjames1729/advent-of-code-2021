# frozen_string_literal: true

require 'json'

# Snailfish (https://adventofcode.com/2021/day/18)
class Eighteen
  def initialize(path)
    @input_path = path
  end

  def self.sum(path)
    new(path).sum
  end

  def self.greatest(path)
    new(path).greatest
  end

  def sum
    numbers.reduce(:+).magnitude
  end

  def greatest
    max = 0
    numbers.each_with_index do |n, i|
      numbers.each_with_index do |m, j|
        if i != j
          value = (n + m).magnitude
          max = value if value > max
        end
      end
    end
    max
  end

  private

  attr_reader :input_path

  def numbers
    @numbers ||= File.readlines(input_path).map do |line|
      SnailfishNumber.new(line.strip)
    end
  end
end

# A Snailfish Number
class SnailfishNumber
  def initialize(text)
    @text = text
  end

  def to_arrays
    JSON.parse(text)
  end

  def +(other)
    self.class.new(reduce([to_arrays, other.to_arrays]).to_json)
  end

  def magnitude
    magnitude_inner(to_arrays)
  end

  private

  attr_reader :text

  def reduce(element)
    loop do
      next if explode(element)

      break unless split(element)
    end
    element
  end

  def explode(element)
    !explode_inner(element, 1).nil?
  end

  def explode_inner(element, level)
    (0..1).each do |index|
      value = element[index]
      next unless value.is_a?(Array)
      return explode_at(element, index) unless level < 4

      result = continue_search(element, index, level)
      return result unless result.nil?
    end
    nil
  end

  def explode_at(element, index)
    value = element[index]
    element[index] = 0
    explode_into(element, index, value[1 - index])
    { index: index, value: value[index] }
  end

  def continue_search(element, index, level)
    result = explode_inner(element[index], level + 1)
    return result if result.nil? || result.empty? || result[:index] == index

    explode_into(element, index, result[:value])
    {}
  end

  def explode_into(element, index, value)
    if element[1 - index].is_a?(Array)
      element = element[1 - index]
      element = element[index] while element[index].is_a?(Array)

      element[index] += value
    else
      element[1 - index] += value
    end
  end

  def split(element)
    (0..1).each do |index|
      value = element[index]
      if value.is_a?(Array)
        return true if split(value)
      elsif value > 9
        element[index] = split_number(value)
        return true
      end
    end
    false
  end

  def split_number(number)
    q, r = number.divmod(2)
    [q, q + r]
  end

  def magnitude_inner(element)
    return element unless element.is_a?(Array)

    (3 * magnitude_inner(element[0])) + (2 * magnitude_inner(element[1]))
  end
end

puts Eighteen.sum('eighteen_example.txt')
puts Eighteen.sum('eighteen.txt')

puts Eighteen.greatest('eighteen_example.txt')
puts Eighteen.greatest('eighteen.txt')

# frozen_string_literal: true

# Seven Segment Search (https://adventofcode.com/2021/day/8)
class Eight
  def initialize(path)
    @input_path = path
  end

  def self.counts(path)
    new(path).counts
  end

  def self.decode(path)
    new(path).decode
  end

  def counts
    segments.reduce(0) do |count, line|
      line[:output].reduce(count) do |inner_count, digit|
        if [2, 3, 4, 7].include?(digit.length)
          inner_count + 1
        else
          inner_count
        end
      end
    end
  end

  def decode
    segments.reduce(0) do |memo, line|
      classify(line)
      fill_decoder

      memo + decode_line(line)
    end
  end

  private

  attr_reader :input_path, :classified, :decoder

  def segments
    @segments ||= File.readlines(input_path).map do |line|
      process_line(line)
    end
  end

  def process_line(line)
    unique = true
    line.strip.split.each_with_object({ unique: [], output: [] }) do |digit, memo|
      if digit == '|'
        unique = false
      elsif unique
        memo[:unique].append(digit.chars.sort)
      else
        memo[:output].append(digit.chars.sort.join)
      end
    end
  end

  def classify(line)
    @classified = line[:unique].each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |digit, result|
      result[digit.length].append(digit)
    end
  end

  def start_fill_decoder
    @decoder = {
      1 => classified[2].first,
      4 => classified[4].first,
      7 => classified[3].first,
      8 => classified[7].first
    }
  end

  def find_digit(classified_index, decoder_index, intersection_size)
    index = classified[classified_index].find_index do |digit|
      intersection = decoder[decoder_index] & digit
      intersection.count == intersection_size
    end
    classified[classified_index].delete_at(index)
  end

  def middle_fill_decoder
    decoder[3] = find_digit(5, 1, 2)
    decoder[9] = find_digit(6, 4, 4)
    decoder[5] = find_digit(5, 9, 5)
    decoder[6] = find_digit(6, 5, 5)
  end

  def finish_fill_decoder
    decoder[2] = classified[5].first
    decoder[0] = classified[6].first
    @decoder = decoder.map { |number, digit| [digit.join, number] }.to_h
  end

  def fill_decoder
    start_fill_decoder
    middle_fill_decoder
    finish_fill_decoder
  end

  def decode_line(line)
    line[:output].reduce(0) do |memo, digit|
      (memo * 10) + decoder[digit]
    end
  end
end

puts Eight.counts('eight_example.txt')
puts Eight.counts('eight.txt')
puts Eight.decode('eight_example.txt')
puts Eight.decode('eight.txt')

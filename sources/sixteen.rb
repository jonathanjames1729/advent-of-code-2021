# frozen_string_literal: true

# Packet Decoder (https://adventofcode.com/2021/day/16)
class Sixteen
  DIGIT_MAP = (0..15).map { |i| [i.to_s(16).upcase, i.digits(2).append(0, 0, 0).slice(0, 4).reverse] }.to_h.freeze
  PACKET_TYPE_MAP = { 0 => :sum, 1 => :prod, 2 => :min, 3 => :max, 4 => :lit, 5 => :>, 6 => :<, 7 => :== }.freeze

  def initialize(path)
    @input_path = path
    @position = 0
  end

  def self.parse(path)
    new(path).parse
  end

  def parse
    self.class.sum_versions(read_packet)
  end

  def self.evaluate(path)
    new(path).evaluate
  end

  def evaluate
    self.class.evaluate_packet(read_packet)
  end

  class << self
    def sum_versions(packet)
      if packet[:type] == :lit
        packet[:version]
      else
        packet[:packets].reduce(packet[:version]) { |sum, sub_packet| sum + sum_versions(sub_packet) }
      end
    end

    def evaluate_packet(packet)
      type = packet[:type]
      return packet[:value] if type == :lit

      evaluate_operator(type, packet[:packets].map { |sub_packet| evaluate_packet(sub_packet) })
    end

    private

    def evaluate_operator(type, values)
      case type
      when :sum, :min, :max
        values.method(type).call
      when :prod
        values.reduce(1) { |result, value| result * value }
      when :<, :>, :==
        values[0].method(type).call(values[1]) ? 1 : 0
      end
    end
  end

  private

  attr_reader :input_path, :position

  def bits
    @bits ||= File.read(input_path).strip.chars.each_with_object([]) do |char, memo|
      memo.concat(DIGIT_MAP[char])
    end
  end

  def read_string(length)
    last_position = position
    @position = last_position + length
    bits.slice(last_position, length)
  end

  def read_bit
    read_string(1).last
  end

  def read_number(length)
    read_string(length).reduce(0) { |value, bit| value * 2 + bit }
  end

  def read_packet
    version = read_number(3)
    type = PACKET_TYPE_MAP[read_number(3)]
    if type == :lit
      read_literal_value_packet(version)
    elsif read_bit.zero?
      read_operator_zero_packet(version, type)
    else
      read_operator_one_packet(version, type)
    end
  end

  def read_literal_value_packet(version)
    result = []
    flag = 1
    length = 6
    while flag == 1
      five_bits = read_string(5)
      flag = five_bits.shift
      result.concat(five_bits)
      length += 5
    end
    { version: version, type: :lit, length: length, value: result.reduce(0) { |value, bit| value * 2 + bit } }
  end

  def read_operator_zero_packet(version, type)
    length = read_number(15)
    current_length = 0
    packets = []
    while current_length < length
      packets.append(read_packet)
      current_length += packets.last[:length]
    end
    { version: version, type: type, length: length + 22, packets: packets }
  end

  def read_operator_one_packet(version, type)
    count = read_number(11)
    packets = (1..count).map { |_| read_packet }
    length = packets.reduce(18) { |value, packet| value + packet[:length] }
    { version: version, type: type, length: length, packets: packets }
  end
end

puts Sixteen.parse('sixteen_example_one.txt')
puts Sixteen.parse('sixteen_example_two.txt')
puts Sixteen.parse('sixteen_example_three.txt')
puts Sixteen.parse('sixteen_example_four.txt')
puts Sixteen.parse('sixteen.txt')

puts Sixteen.evaluate('sixteen_example_five.txt')
puts Sixteen.evaluate('sixteen_example_six.txt')
puts Sixteen.evaluate('sixteen_example_seven.txt')
puts Sixteen.evaluate('sixteen_example_eight.txt')
puts Sixteen.evaluate('sixteen_example_nine.txt')
puts Sixteen.evaluate('sixteen_example_ten.txt')
puts Sixteen.evaluate('sixteen_example_eleven.txt')
puts Sixteen.evaluate('sixteen_example_twelve.txt')
puts Sixteen.evaluate('sixteen.txt')

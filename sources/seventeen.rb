# frozen_string_literal: true

# Trick Shot (https://adventofcode.com/2021/day/17
class Seventeen
  TARGET_AREA_RE = /^target area: x=(-?\d+)\.\.(-?\d+), y=(-?\d+)\.\.(-?\d+)$/.freeze

  def initialize(path)
    @input_path = path
  end

  def self.find_velocity(path)
    new(path).find_velocity
  end

  def find_velocity
    vertical_velocities.each_with_object([]) do |v_y, velocities|
      (1...).each do |v_x|
        case check_starting_velocity([v_x, v_y])
        when :hit
          velocities.append("#{v_x},#{v_y}")
        when :overshot
          break
        end
      end
    end.uniq.count
  end

  private

  attr_reader :input_path

  def target_area
    @target_area ||= File.read(input_path).strip.match(TARGET_AREA_RE).yield_self do |match|
      [(match[1].to_i..match[2].to_i), (match[3].to_i..match[4].to_i)]
    end
  end

  def vertical_velocities
    min_y = target_area[1].min
    (min_y..(1 - min_y))
  end

  def hit?(position)
    target_area.each_with_index do |range, index|
      return false unless range.include?(position[index])
    end
    true
  end

  def undershot?(position)
    position[1] < target_area[1].min
  end

  def overshot?(position)
    position[0] > target_area[0].max
  end

  def check_starting_velocity(velocity)
    position = [0, 0]
    loop do
      position = [0, 1].map { |index| position[index] + velocity[index] }
      velocity = [velocity[0] - (velocity[0] <=> 0), velocity[1] - 1]
      return :hit if hit?(position)
      return :undershot if undershot?(position)
      return :overshot if overshot?(position)
    end
  end
end

puts Seventeen.find_velocity('seventeen_example.txt')
puts Seventeen.find_velocity('seventeen.txt')

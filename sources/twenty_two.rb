# frozen_string_literal: true

require 'pry'
require 'set'

# Reactor Reboot (https://adventofcode.com/2021/day/22)
class TwentyTwo
  def initialize(path)
    @input_path = path
  end

  def self.initialization(path)
    new(path).initialization
  end

  def self.reboot(path)
    new(path).reboot
  end

  def initialization
    reboot_steps.each_with_object(Set.new) do |step, points|
      step.each_point((-50..50)) do |x, y, z|
        point = "#{x},#{y},#{z}"
        if step.state == :on
          points.add(point)
        else
          points.delete(point)
        end
      end
    end.size
  end

  def reboot
    result = []
    reboot_steps.each do |step|
      intersections = result.map { |other_step| other_step & step }.compact
      result.append(step) if step.state == :on
      result.concat(intersections)
    end
    result.reduce(0) { |sum, step| sum + step.size }
  end

  private

  attr_reader :input_path

  def reboot_steps
    @reboot_steps ||= File.readlines(input_path).map do |line|
      RebootStep.load(line.strip)
    end
  end
end

# Reboot Step data
class RebootStep
  attr_reader :state

  def initialize(state, ranges)
    @state = state
    @ranges = ranges
  end

  def each_point(restriction = nil, &blk)
    intervals = ranges.map do |range|
      if restriction.nil?
        range.to_a
      else
        range.to_a & restriction.to_a
      end
    end
    intervals[0].each { |x| intervals[1].each { |y| intervals[2].each { |z| blk.call(x, y, z) } } }
  end

  def size
    (state == :on ? 1 : -1) * ranges.reduce(1) { |product, range| product * range.size }
  end

  def [](index)
    ranges[index]
  end

  def &(other)
    intersection = [0, 1, 2].map do |i|
      self.class.intersect_ranges(ranges[i], other[i]) || self.class.intersect_ranges(other[i], ranges[i])
    end
    intersection.all? ? self.class.new(intersection_state, intersection) : nil
  end

  class << self
    STEP_RE = /(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)/.freeze

    def load(line)
      match = STEP_RE.match(line)
      new(match[1].to_sym, [1, 2, 3].map { |i| (match[2 * i].to_i..match[2 * i + 1].to_i) })
    end

    def intersect_ranges(one, two)
      return unless one.include?(two.min)

      if one.include?(two.max)
        (two.min..two.max)
      elsif two.include?(one.max)
        (two.min..one.max)
      end
    end
  end

  private

  attr_reader :ranges

  def intersection_state
    state == :on ? :off : :on
  end
end

puts TwentyTwo.initialization('twenty_two_example_one.txt')
puts TwentyTwo.initialization('twenty_two.txt')

puts TwentyTwo.reboot('twenty_two_example_two.txt')
puts TwentyTwo.reboot('twenty_two.txt')

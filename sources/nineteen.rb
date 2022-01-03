# frozen_string_literal: true

require 'pry'

# Beacon Scanner (https://adventofcode.com/2021/day/19)
class Nineteen
  SCANNER_RE = /^--- scanner (\d+) ---$/.freeze
  PROBE_RE = /^(-?\d+),(-?\d+),(-?\d+)$/.freeze
  PERMUTATIONS = [
    { permutation: [0, 1, 2].freeze, sign: 1 }.freeze,
    { permutation: [0, 2, 1].freeze, sign: -1 }.freeze,
    { permutation: [1, 0, 2].freeze, sign: -1 }.freeze,
    { permutation: [1, 2, 0].freeze, sign: 1 }.freeze,
    { permutation: [2, 0, 1].freeze, sign: 1 }.freeze,
    { permutation: [2, 1, 0].freeze, sign: -1 }.freeze
  ].freeze
  SIGNS = [[1, 1, 1].freeze, [1, -1, -1].freeze, [-1, 1, -1].freeze, [-1, -1, 1].freeze].freeze

  def initialize(path)
    @input_path = path
  end

  def count_beacons
    beacons.count
  end

  def max_scanner_distance
    beacons
    max_distance = 0
    scanners.combination(2) do |one, two|
      distance = manhatten_distance(one[:position], two[:position])
      max_distance = distance if distance > max_distance
    end
    max_distance
  end

  private

  attr_reader :input_path

  def scanners
    @scanners ||= File.readlines(input_path).each_with_object([]) do |line, memo|
      match = SCANNER_RE.match(line)
      if match.nil?
        match = PROBE_RE.match(line)
        next if match.nil?

        memo.last[:beacons].append(match.values_at(1, 2, 3).map(&:to_i).freeze)
      else
        memo.append({ beacons: [], position: nil })
      end
    end
  end

  def beacons
    @beacons ||= collect_beacons
  end

  def per_component(one, two, &blk)
    [0, 1, 2].map { |i| blk.call(one[i], two[i]) }.freeze
  end

  def manhatten_distance(one, two)
    per_component(one, two, &:-).map(&:abs).sum
  end

  def each_transform(beacons, &blk)
    PERMUTATIONS.each do |permutation:, sign:|
      permuted_beacons = beacons.map do |beacon|
        [0, 1, 2].map { |i| beacon[permutation[i]] }
      end
      SIGNS.each do |signs|
        blk.call(permuted_beacons.map do |beacon|
          per_component(beacon, signs) { |one, two| one * two * sign }
        end)
      end
    end
  end

  def check_intersections(beacons, transformed_beacons)
    beacons.each do |beacon|
      transformed_beacons.each do |potential_match_beacon|
        potential_scanner_position = per_component(beacon, potential_match_beacon, &:-)
        translated_beacons = transformed_beacons.map { |b| per_component(b, potential_scanner_position, &:+) }
        intersect = beacons & translated_beacons
        return translated_beacons, potential_scanner_position if intersect.count >= 12
      end
    end
    nil
  end

  def check_scanner_against_beacons(beacons, scanner)
    each_transform(scanner[:beacons]) do |transformed_beacons|
      result = check_intersections(beacons, transformed_beacons)
      next if result.nil?

      beacons.concat(result[0]).uniq!
      scanner[:position] = result[1]
      return true
    end
    false
  end

  def collect_beacons
    beacons = scanners.first[:beacons].dup
    scanners.first[:position] = [0, 0, 0]
    loop do
      action = false
      scanners.each do |scanner|
        next unless scanner[:position].nil?

        action = check_scanner_against_beacons(beacons, scanner) || action
      end
      return beacons unless action
    end
  end
end

example = Nineteen.new('nineteen_example.txt')
puts example.count_beacons
puts example.max_scanner_distance
actual = Nineteen.new('nineteen.txt')
puts actual.count_beacons
puts actual.max_scanner_distance

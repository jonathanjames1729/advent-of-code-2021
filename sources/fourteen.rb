# frozen_string_literal: true

# Extended Polymerization (https://adventofcode.com/2021/day/14)
class Fourteen
  def initialize(path, repeats)
    @input_path = path
    @times = repeats
    @components = []
    @totals = {}
  end

  def self.apply_rules(path, repeats)
    new(path, repeats).apply_rules
  end

  def apply_rules
    load
    generate_insertion_rules
    left = nil
    polymer_template.each_char do |right|
      count_char(right)
      update_char_counts(lookup_insertion_rules(times, left, right)[:counts]) unless left.nil?
      left = right
    end
    score
  end

  private

  attr_reader :input_path, :times, :polymer_template, :insertion_rules, :components, :totals

  def load
    lines = File.readlines(input_path).map(&:strip)
    @polymer_template = lines.shift
    raise 'Error' unless lines.shift.empty?

    @insertion_rules = {
      1 => lines.each_with_object({}) do |line, rules|
        match = /([A-Z][A-Z]) -> ([A-Z])/.match(line)
        rules[match[1]] = { rules: [match[2]], counts: { match[2] => 1 } }
      end
    }
    find_components
  end

  def find_components
    index = 1
    while index <= times
      components.append(index) if times.anybits?(index)
      index *= 2
    end
  end

  def count_char(char, counts = nil)
    counts ||= totals
    value = counts[char]
    counts[char] = value.nil? ? 1 : (value + 1)
  end

  def empty_rule(generate_rules)
    generate_rules ? { rules: [], counts: {} } : { counts: {} }
  end

  def lookup_insertion_rules(via_index, left, right)
    fill = insertion_rules[via_index]["#{left}#{right}"]
    fill.nil? ? empty_rule(via_index < components.last) : fill
  end

  def update_char_counts(sub_counts, counts = nil)
    counts ||= totals
    sub_counts.each do |key, value|
      current = counts[key]
      counts[key] = current.nil? ? value : (current + value)
    end
  end

  def produce_rules_inner(via_index, left, right, include_right, rule)
    lookup = lookup_insertion_rules(via_index, left, right)
    rule[:rules]&.concat(lookup[:rules])
    update_char_counts(lookup[:counts], rule[:counts])
    return unless include_right

    rule[:rules]&.append(right)
    count_char(right, rule[:counts])
  end

  def produce_rules(from_index, via_index, generate_rules)
    insertion_rules[from_index].each_with_object({}) do |(key, value), rules|
      left = key[0]
      rules[key] = value[:rules].each_with_object(empty_rule(generate_rules)) do |right, rule|
        produce_rules_inner(via_index, left, right, true, rule)
        left = right
      end
      produce_rules_inner(via_index, left, key[1], false, rules[key])
    end
  end

  def generate_insertion_rules_powers_of_two
    from_index = 1
    while from_index < components.last
      to_index = from_index * 2
      insertion_rules[to_index] = produce_rules(from_index, from_index, (to_index < components.last))
      from_index = to_index
    end
  end

  def generate_insertion_rules
    generate_insertion_rules_powers_of_two
    from_index = 0
    components.each do |via_index|
      to_index = from_index + via_index
      insertion_rules[to_index] = produce_rules(from_index, via_index, (to_index < times)) unless from_index.zero?
      from_index = to_index
    end
  end

  def score
    min, max = totals.values.minmax
    max - min
  end
end

puts Fourteen.apply_rules('fourteen_example.txt', 10)
puts Fourteen.apply_rules('fourteen.txt', 10)

puts Fourteen.apply_rules('fourteen_example.txt', 20)
puts Fourteen.apply_rules('fourteen.txt', 20)

puts Fourteen.apply_rules('fourteen_example.txt', 40)
puts Fourteen.apply_rules('fourteen.txt', 40)

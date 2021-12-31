# frozen_string_literal: true

# Chiton (https://adventofcode.com/2021/day/15)
class Fifteen
  def initialize(path)
    @input_path = path
    @risks = []
  end

  def self.min_total_risk(path)
    new(path).min_total_risk
  end

  def min_total_risk
    setup_risks
    loop { break risks[max_y][max_x] unless refine_risks }
  end

  def self.expanded_min_total_risk(path)
    new(path).expanded_min_total_risk
  end

  def expanded_min_total_risk
    expand
    setup_risks
    loop { break risks[max_y][max_x] unless refine_risks }
  end

  private

  attr_reader :input_path, :risks

  def map
    @map ||= File.readlines(input_path).map do |line|
      line.strip.chars.map(&:to_i)
    end
  end

  def max_x
    @max_x ||= (map.first.count - 1)
  end

  def max_y
    @max_y ||= (map.count - 1)
  end

  def setup_risk_first_column(risk, y_pos)
    risks.append(y_pos.zero? ? [0] : [risks[y_pos - 1][0] + risk])
  end

  def setup_risk(risk, x_pos, y_pos)
    values = [risks[y_pos][x_pos - 1]]
    values.append(risks[y_pos - 1][x_pos]) unless y_pos.zero?
    risks.last.append(values.min + risk)
  end

  def setup_risks
    map.each_with_index do |line, y|
      line.each_with_index do |risk, x|
        if x.zero?
          setup_risk_first_column(risk, y)
        else
          setup_risk(risk, x, y)
        end
      end
    end
  end

  def adjacent(x_pos, y_pos)
    yield [x_pos, y_pos - 1] unless y_pos.zero?
    yield [x_pos - 1, y_pos] unless x_pos.zero?
    yield [x_pos, y_pos + 1] unless y_pos == max_y
    yield [x_pos + 1, y_pos] unless x_pos == max_x
  end

  def min_adjacent_risk(risk, x_pos, y_pos)
    values = []
    adjacent(x_pos, y_pos) { |x, y| values.append(risk + risks[y][x]) }
    values.min
  end

  def update_risk(risk, x_pos, y_pos)
    candidate = min_adjacent_risk(risk, x_pos, y_pos)
    return false unless candidate < risks[y_pos][x_pos]

    risks[y_pos][x_pos] = candidate
    true
  end

  def refine_risks
    changed = false
    map.each_with_index do |line, y|
      line.each_with_index do |risk, x|
        changed = true if update_risk(risk, x, y)
      end
    end
    changed
  end

  def increase_risk(risk)
    risk == 9 ? 1 : risk + 1
  end

  def expand_horizontally
    map.each do |line|
      (0...(4 * line.count)).each do |x|
        line.append(increase_risk(line[x]))
      end
    end
    @max_x = map.first.count - 1
  end

  def expand_vertically
    (0...(4 * map.count)).each do |y|
      map.append(map[y].map { |risk| increase_risk(risk) })
    end
    @max_y = map.count - 1
  end

  def expand
    expand_horizontally
    expand_vertically
  end
end

puts Fifteen.min_total_risk('fifteen_example.txt')
puts Fifteen.min_total_risk('fifteen.txt')
puts Fifteen.expanded_min_total_risk('fifteen_example.txt')
puts Fifteen.expanded_min_total_risk('fifteen.txt')

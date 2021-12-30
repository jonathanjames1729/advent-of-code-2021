# frozen_string_literal: true

require 'pry'

# Arithmetic Logic Unit (https://adventofcode.com/2021/day/24)
class TwentyFour
  INPUT_RE = /^inp ([w-z])$/.freeze
  INSTRUCTION_RE = /^(add|mul|div|mod|eql) ([w-z]) ([w-z]|-?\d+)$/.freeze
  INSTRUCTION_MAP = { 'add' => :+, 'mul' => :*, 'div' => :/, 'mod' => :%, 'eql' => :eql }.freeze
  VARIABLE_NAMES = 'wxyz'.chars.freeze

  def initialize(path)
    @input_path = path
    @variables = VARIABLE_NAMES.map { |name| [name, 0] }.to_h
  end

  def self.evaluate(path, number)
    new(path).evaluate(number)
  end

  def evaluate(number)
    run_program(number)
  end

  private

  attr_reader :input_path, :variables

  def program
    @program ||= File.readlines(input_path).each_with_object([]) do |line, memo|
      match = INPUT_RE.match(line)
      if match.nil?
        instruction, operand_one, operand_two = INSTRUCTION_RE.match(line).values_at(1, 2, 3)
        next unless add_instruction(memo.last[:program], INSTRUCTION_MAP[instruction], operand_one, operand_two)
      else
        memo.append({ input: match[1], program: [] })
      end
    end
  end

  def add_instruction(program, instruction, operand_one, operand_two)
    if VARIABLE_NAMES.include?(operand_two)
      program.append([instruction, operand_one, true, operand_two])
    else
      return false if noop?(instruction, operand_two)

      program.append([instruction, operand_one, false, operand_two.to_i])
    end
    true
  end

  def noop?(instruction, operand_two)
    case operand_two
    when '0'
      return true if instruction == :+
    when '1'
      return true if %i[* /].include?(instruction)
    end
    false
  end

  def run_instruction(instruction, operand_one, flag, operand_two)
    value = flag ? variables[operand_two] : operand_two
    if instruction == :eql
      variables[operand_one] == value ? 1 : 0
    else
      variables[operand_one].method(instruction).call(value)
    end
  end

  def model_number_valid?
    variables['z'].zero?
  end

  def run_step(step, input)
    variables[program[step][:input]] = input
    program[step][:program].each do |instruction, operand_one, flag, operand_two|
      variables[operand_one] = run_instruction(instruction, operand_one, flag, operand_two)
    end
  end

  def run_program(number)
    number.digits.reverse.each_with_index { |input, index| run_step(index, input) }
    model_number_valid?
  end
end

puts TwentyFour.evaluate('twenty_four.txt', 51_939_397_989_999)
puts TwentyFour.evaluate('twenty_four.txt', 11_717_131_211_195)

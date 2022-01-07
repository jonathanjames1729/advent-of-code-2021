# frozen_string_literal: true

# Amphipod (https://adventofcode.com/2021/day/23)
class TwentyThree
  PATH = {
    A: [[1], [], [], [2], [2, 3], [2, 3, 4], [2, 3, 4, 5]],
    B: [[1, 2], [2], [], [], [3], [3, 4], [3, 4, 5]],
    C: [[1, 2, 3], [2, 3], [3], [], [], [4], [4, 5]],
    D: [[1, 2, 3, 4], [2, 3, 4], [3, 4], [4], [], [], [5]]
  }.freeze
  DISTANCE = {
    A: [3, 2, 2, 4, 6, 8, 9],
    B: [5, 4, 2, 2, 4, 6, 7],
    C: [7, 6, 4, 2, 2, 4, 5],
    D: [9, 8, 6, 4, 2, 2, 3]
  }.freeze
  COST = { A: 1, B: 10, C: 100, D: 1000 }.freeze
  EXTRAS = { A: %i[D D], B: %i[B C], C: %i[A B], D: %i[C A] }.freeze

  def initialize(path, extra)
    @input_path = path
    @extras_included = extra
    @min_cost = extra ? 1111 * 4 * 24 : 1111 * 2 * 20
  end

  def self.find_min_cost(path, extra)
    new(path, extra).find_min_cost
  end

  def find_min_cost
    move(0)
    min_cost
  end

  private

  attr_reader :input_path, :extras_included, :min_cost

  def states
    @states ||= begin
      rooms = initial_rooms
      [
        {
          rooms: rooms,
          hallway: Array.new(7, nil),
          cost: initial_cost(rooms)
        }
      ]
    end
  end

  def initial_rooms
    lines = File.readlines(input_path).values_at(3, 2).map { |line| line.chars.values_at(3, 5, 7, 9).map(&:to_sym) }
    %i[A B C D].zip(lines.transpose).map do |label, room|
      [label, extras_included ? room.insert(1, *EXTRAS[label]) : room]
    end.to_h
  end

  def initial_cost(rooms)
    rooms.reduce(0) do |cost, (label, room)|
      index = room.find_index { |content| content != label }
      max = room.count - 1
      index = max if index.nil?
      (index..max).reduce(cost) { |c, i| c + ((max - i) * (COST[room[i]] + COST[label])) }
    end
  end

  def finished?(step)
    return false if states[step][:hallway].any?

    states[step][:rooms].each { |label, room| return false unless room.all?(label) }
    true
  end

  def path_blocked?(state, room_label, hallway_position)
    PATH[room_label][hallway_position].map { |route_position| state[:hallway][route_position] }.any?
  end

  def create_state(step)
    state = states[step]
    states[step + 1] = {
      rooms: state[:rooms].transform_values(&:dup),
      hallway: state[:hallway].dup,
      cost: state[:cost]
    }
  end

  def move_from_hallway(step, amphipod, hallway_position)
    next_state = create_state(step)
    room = next_state[:rooms][amphipod]
    next_state[:hallway][hallway_position] = nil
    room.append(amphipod)
    move(step + 1)
  end

  def moves_from_hallway(step)
    state = states[step]
    state[:hallway].each_with_index do |space, position|
      next if space.nil?
      next unless state[:rooms][space].all?(space)
      next if path_blocked?(state, space, position)

      move_from_hallway(step, space, position)
    end
  end

  def total_journey_cost(amphipod, room_label, hallway_position)
    COST[amphipod] * (DISTANCE[room_label][hallway_position] + DISTANCE[amphipod][hallway_position])
  end

  def move_from_room(step, room_label, hallway_position)
    next_state = create_state(step)
    amphipod = next_state[:rooms][room_label].pop
    next_state[:hallway][hallway_position] = amphipod
    next_state[:cost] += total_journey_cost(amphipod, room_label, hallway_position)
    move(step + 1)
  end

  def moves_from_rooms(step)
    state = states[step]
    state[:rooms].each do |label, room|
      next if room.all?(label)

      state[:hallway].each_with_index do |space, position|
        next unless space.nil?
        next if path_blocked?(state, label, position)

        move_from_room(step, label, position)
      end
    end
  end

  def move(step)
    cost = states[step][:cost]
    if finished?(step)
      @min_cost = cost if cost < min_cost
      return
    end
    return if cost >= min_cost

    moves_from_hallway(step)
    moves_from_rooms(step)
  end
end

puts TwentyThree.find_min_cost('twenty_three_example.txt', false)
puts TwentyThree.find_min_cost('twenty_three_example.txt', true)
puts TwentyThree.find_min_cost('twenty_three.txt', false)
puts TwentyThree.find_min_cost('twenty_three.txt', true)

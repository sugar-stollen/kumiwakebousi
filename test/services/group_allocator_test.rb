require 'test_helper'

class GroupAllocatorTest < ActiveSupport::TestCase
  test 'avoids previously used pairs when an entirely new grouping is possible' do
    participants = build_list(:participant, 4)
    new_pairs = [participants.first(2), participants.last(2)].map do |pair|
      pair.map { |participant| participant['id'] }.sort
    end
    history = participants.combination(2).map do |first, second|
      [first['id'], second['id']].sort
    end - new_pairs

    groups = GroupAllocator.new(
      members: participants,
      group_count: 2,
      history: history
    ).call

    actual_pairs = groups.flat_map do |group|
      group.combination(2).map { |first, second| [first['id'], second['id']].sort }
    end
    assert_equal new_pairs, actual_pairs.sort
  end

  test 'distributes the remainder so group sizes differ by at most one' do
    participants = build_list(:participant, 5)

    groups = GroupAllocator.new(members: participants, group_count: 2).call

    assert_equal [2, 3], groups.map(&:size).sort
    assert_equal participants.map { |participant| participant['id'] }.sort,
                 groups.flatten.map { |participant| participant['id'] }.sort
  end

  test 'calculates the maximum number of rounds from all possible pairs' do
    assert_equal 5, GroupAllocator.maximum_rounds(member_count: 6, group_count: 3)
    assert_equal 0, GroupAllocator.maximum_rounds(member_count: 2, group_count: 0)
  end
end

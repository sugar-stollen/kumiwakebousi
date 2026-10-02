# frozen_string_literal: true

class GroupAllocator
  def self.maximum_rounds(member_count:, group_count:)
    return 0 if member_count < 2 || group_count < 1

    total_pairs = member_count * (member_count - 1) / 2
    base_size = member_count / group_count
    remainder = member_count % group_count

    pairs_per_round = group_count.times.sum do |index|
      size = base_size + (index < remainder ? 1 : 0)
      size * (size - 1) / 2
    end

    return 0 if pairs_per_round.zero?

    total_pairs / pairs_per_round
  end

  def initialize(members:, group_count:, history: [])
    @members = members
    @group_count = group_count
    @history = history
  end

  def call
    best_groups = nil
    best_score = -1

    1000.times do
      groups = make_random_groups
      score = calculate_score(groups)
      best_groups, best_score = improved_result(best_groups, best_score, groups, score)
      return groups if score == total_pairs_per_round
    end

    best_groups
  end

  # 全員のペアをすでに経験しているか
  def all_pairs_used?
    all_pairs.all? do |pair|
      @history.include?(pair)
    end
  end

  private

  def make_random_groups
    shuffled_members = @members.shuffle
    start_index = 0

    make_group_sizes.map do |group_size|
      group = shuffled_members[start_index, group_size]
      start_index += group_size
      group
    end
  end

  def calculate_score(groups)
    groups.sum do |group|
      group.combination(2).count do |member_a, member_b|
        !@history.include?([member_a['id'], member_b['id']].sort)
      end
    end
  end

  def improved_result(best_groups, best_score, groups, score)
    return [groups, score] if score > best_score

    [best_groups, best_score]
  end

  def total_pairs_per_round
    make_group_sizes.sum do |size|
      size * (size - 1) / 2
    end
  end

  def make_group_sizes
    base_size = @members.length / @group_count
    remainder = @members.length % @group_count

    Array.new(@group_count) do |i|
      base_size + (i < remainder ? 1 : 0)
    end
  end

  # 全メンバーの組み合わせ
  def all_pairs
    @members.combination(2).map do |member_a, member_b|
      [member_a['id'], member_b['id']].sort
    end
  end
end

class GroupAllocator
  def initialize(members:, group_count:, history: [])
    @members = members
    @group_count = group_count
    @history = history
  end

  def call
    1000.times do
      groups = make_random_groups
      score = calculate_score(groups)

      # 今回の組み合わせがすべて新しいなら採用
      return groups if score == total_pairs_per_round
    end

    # 完全に新しい組み合わせを作れなかった
    nil
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

    base_size = @members.length / @group_count
    remainder = @members.length % @group_count

    groups = []
    start_index = 0

    @group_count.times do |i|
      group_size = base_size
      group_size += 1 if i < remainder

      groups << shuffled_members[start_index, group_size]
      start_index += group_size
    end

    groups
  end

  def calculate_score(groups)
    score = 0

    groups.each do |group|
      group.combination(2).each do |member_a, member_b|
        pair = [member_a["id"], member_b["id"]].sort

        score += 1 unless @history.include?(pair)
      end
    end

    score
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
      [member_a["id"], member_b["id"]].sort
    end
  end
end
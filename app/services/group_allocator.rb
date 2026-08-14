class GroupAllocator
  def initialize(members:, group_count:)
    @members = members
    @group_count = group_count
  end

  def call
    shuffled_members = @members.shuffle

    base_size = @members.length / @group_count
    remainder = @members.length % @group_count

    groups = []
    start_index = 0

    @group_count.times do |i|
      group_size = base_size

      # 余りがある場合、最初のグループから1人ずつ多くする
      group_size += 1 if i < remainder

      groups << shuffled_members[start_index, group_size]
      start_index += group_size
    end

    groups
  end
end
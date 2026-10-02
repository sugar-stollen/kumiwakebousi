# frozen_string_literal: true

class GroupNames
  def initialize(names)
    @names = Array(names)
  end

  def call
    @names.each_with_index.map do |name, index|
      name.presence || "#{('A'.ord + index).chr}組"
    end
  end
end

# frozen_string_literal: true

class ParticipantRoster
  MINIMUM_SIZE = 3

  def initialize(names)
    @names = Array(names).reject(&:blank?)
  end

  def valid?
    @names.length >= MINIMUM_SIZE
  end

  def to_session
    @names.each_with_index.map do |name, index|
      { 'id' => index + 1, 'name' => name }
    end
  end
end

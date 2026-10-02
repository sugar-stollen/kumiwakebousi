# frozen_string_literal: true

class KumiwakePairHistory
  def self.restore(serialized_pairs)
    Array(serialized_pairs).filter_map do |pair|
      case pair
      when Array
        pair.map(&:to_i)
      when String
        pair.split(':', 2).map(&:to_i) if pair.include?(':')
      end
    end
  end
end

# frozen_string_literal: true

module KumiwakeSessionState
  private

  def restore_groups(groups)
    return nil if groups.nil?

    members = session_members_by_id
    Array(groups).map { |group| restore_group(group, members) }
  end

  def clear_round_state
    session.delete(:group_history)
    session.delete(:current_groups)
    session.delete(:draw_count)
    session.delete(:round_number)
    session.delete(:past_results)
    session.delete(:kumiwake_limit_reached)
    session.delete(:avoid_repeat_mode)
    session.delete(:_switch_complete)
  end

  def session_members_by_id
    Array(session[:names]).to_h do |member|
      id = member['id'] || member[:id]
      [id.to_i, member]
    end
  end

  def restore_group(group, members)
    Array(group).filter_map do |member|
      member.is_a?(Hash) ? member : members[member.to_i]
    end
  end
end

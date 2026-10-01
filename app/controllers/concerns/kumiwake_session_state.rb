module KumiwakeSessionState
  private

  def restore_groups(groups)
    return nil if groups.nil?

    members_by_id = Array(session[:names]).each_with_object({}) do |member, members|
      id = member['id'] || member[:id]
      members[id.to_i] = member
    end

    Array(groups).map do |group|
      Array(group).filter_map do |member|
        if member.is_a?(Hash)
          member
        else
          members_by_id[member.to_i]
        end
      end
    end
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
end

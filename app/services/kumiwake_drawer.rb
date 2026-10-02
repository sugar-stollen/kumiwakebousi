# frozen_string_literal: true

class KumiwakeDrawer
  Result = Struct.new(:status, :groups, keyword_init: true) do
    def drawn?
      status == :drawn
    end
  end

  def initialize(session:, params:)
    @session = session
    @params = params
  end

  def call
    switch_to_normal_mode if normal_mode_requested?
    initialize_mode_from_params

    avoid_repeat_mode = @session[:avoid_repeat_mode] == true
    history = drawing_history(avoid_repeat_mode)

    return limit_reached if pair_limit_reached?(avoid_repeat_mode, history)

    groups = allocate_groups(history)
    return unavailable(avoid_repeat_mode) unless groups

    save_drawn_groups(groups, avoid_repeat_mode, history)
    Result.new(status: :drawn, groups: groups)
  end

  private

  def normal_mode_requested?
    @params[:switch_to_normal] == 'true' ||
      @params[:normal_mode] == 'true' ||
      @params[:avoid_repeat_mode] == 'false'
  end

  def switch_to_normal_mode
    @session[:avoid_repeat_mode] = false
    @session.delete(:group_history)
    @session.delete(:past_results)
    @session.delete(:kumiwake_limit_reached)
    @session[:_switch_complete] = true
  end

  def initialize_mode_from_params
    return unless @session[:avoid_repeat_mode].nil? && @params[:avoid_repeat_mode].present?

    @session[:avoid_repeat_mode] = @params[:avoid_repeat_mode] == 'true'
  end

  def drawing_history(avoid_repeat_mode)
    return [] unless avoid_repeat_mode && !@session[:_switch_complete]

    KumiwakePairHistory.restore(@session[:group_history])
  end

  def pair_limit_reached?(avoid_repeat_mode, history)
    return false unless avoid_repeat_mode

    total_pairs = @session[:names].length * (@session[:names].length - 1) / 2
    history.uniq.length >= total_pairs
  end

  def limit_reached
    @session[:avoid_repeat_mode] = true
    @session[:kumiwake_limit_reached] = true
    @session.delete(:_switch_complete)
    Result.new(status: :limit)
  end

  def allocate_groups(history)
    GroupAllocator.new(
      members: @session[:names],
      group_count: @session[:group_count],
      history: history
    ).call
  end

  def unavailable(avoid_repeat_mode)
    @session[:kumiwake_limit_reached] = true if avoid_repeat_mode
    Result.new(status: :unavailable)
  end

  def save_drawn_groups(groups, avoid_repeat_mode, history)
    compact_groups = compact_groups(groups)
    @session[:current_groups] = compact_groups
    @session[:draw_count] = @session[:draw_count].to_i + 1
    @session[:round_number] = @session[:draw_count]
    save_past_result(compact_groups) if avoid_repeat_mode
    save_history(groups, history) if avoid_repeat_mode && !@session[:_switch_complete]
    @session.delete(:_switch_complete)
  end

  def save_past_result(groups)
    past_results = @session[:past_results] || []
    past_results << {
      round: @session[:round_number],
      groups: groups,
      round_draw_count: @session[:draw_count]
    }
    @session[:past_results] = past_results
  end

  def save_history(groups, history)
    groups.each do |group|
      group.combination(2).each do |member_a, member_b|
        pair = [member_a['id'], member_b['id']].sort
        history << pair unless history.include?(pair)
      end
    end

    @session[:group_history] = history.map { |member_a, member_b| "#{member_a}:#{member_b}" }
  end

  def compact_groups(groups)
    groups.map do |group|
      group.map { |member| member['id'] || member[:id] }
    end
  end
end

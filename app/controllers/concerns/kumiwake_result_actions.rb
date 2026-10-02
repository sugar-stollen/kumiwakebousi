# frozen_string_literal: true

module KumiwakeResultActions
  extend ActiveSupport::Concern

  def result
    last_result = latest_result
    @groups = restore_groups(stored_groups(last_result))

    return redirect_to kumiwake_path unless @groups

    assign_result_details(last_result)
  end

  def history
    @group_names = session[:group_names] || []
    @past_results = Array(session[:past_results]).filter_map do |result|
      next unless result.is_a?(Hash)

      {
        'round' => result['round'] || result[:round],
        'groups' => restore_groups(result['groups'] || result[:groups]),
        'round_draw_count' => result['round_draw_count'] || result[:round_draw_count]
      }
    end
  end

  private

  def latest_result
    Array(session[:past_results]).compact.last
  end

  def stored_groups(last_result)
    session[:current_groups] || last_result&.dig('groups') || last_result&.dig(:groups)
  end

  def assign_result_details(last_result)
    @group_names = session[:group_names] || []
    assign_round_details(last_result)
    assign_history_details
  end

  def assign_round_details(last_result)
    @draw_count = session[:draw_count].to_i
    @draw_count = last_result['round_draw_count'].to_i if @draw_count.zero? && last_result.present?
    @round_number = @draw_count.positive? ? @draw_count : 1
  end

  def assign_history_details
    @avoid_repeat_mode = session[:avoid_repeat_mode] == true
    @past_results = Array(session[:past_results]).compact
    @show_history_button = @avoid_repeat_mode && @past_results.length >= 2
  end
end

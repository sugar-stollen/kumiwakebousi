class KumiwakeController < ApplicationController
  include KumiwakeSessionState

  before_action :migrate_legacy_mode_key

  def index
    clear_round_state if params[:new] == 'true'

    @names = session[:names] || []

    @from_name_input = session.delete(:from_name_input)
    @from_group_name_input = session.delete(:from_group_name_input)

    # 魔法の上限に到達したときだけ true
    # JS が index 画面で上限到達時のセリフを表示するため、ここでは削除しない
    @kumiwake_limit_reached = session[:kumiwake_limit_reached]

    # 現在のモード
    @avoid_repeat_mode = session[:avoid_repeat_mode]

    # 魔法の理論上限回数
    @magic_max_rounds = magic_max_rounds
  end

  # ========================================
  # 履歴のリセット
  # ========================================

  def reset_history
    clear_round_state
    head :no_content
  end

  def input
  end

  # ========================================
  # 名簿保存
  # ========================================

  def save_names
    names = params[:names].reject(&:blank?)

    # 登録番号付きで保存
    session[:names] = names.each_with_index.map do |name, index|
      {
        'id' => index + 1,
        'name' => name
      }
    end

    # 新しい組み分けを始める
    clear_round_state

    session[:from_name_input] = true

    redirect_to kumiwake_path
  end

  # ========================================
  # グループ名保存
  # ========================================

  def save_group_names
    clear_round_state

    group_names = params[:group_names]

    group_names = group_names.each_with_index.map do |name, index|
      name.presence || "#{('A'.ord + index).chr}組"
    end

    session[:group_names] = group_names
    session[:group_count] = group_names.length

    session[:from_group_name_input] = true

    redirect_to kumiwake_path
  end

  # ========================================
  # 組名入力画面
  # ========================================

  def group_names
    @names = session[:names] || []

    # 最大組数は「名簿人数 - 1」
    @max_group_count = @names.length - 1
  end

  # ========================================
  # 組み分け実行
  # ========================================

  def draw
    # ========================================
    # 上限後の「続ける」
    # ここは最優先で通常モードへ切り替える
    # ========================================
    if params[:switch_to_normal] == 'true' || params[:normal_mode] == 'true' || params[:avoid_repeat_mode] == 'false'
      session[:avoid_repeat_mode] = false
      session.delete(:group_history)
      session.delete(:past_results)
      session.delete(:kumiwake_limit_reached)
      session[:_switch_complete] = true
    end

    # ========================================
    # 最初の抽選時だけモードを保存
    # ========================================
    #
    # session[:avoid_repeat_mode] がまだ存在しない場合だけ
    # JSから送られてきた avoid_repeat_mode を採用する
    #
    if session[:avoid_repeat_mode].nil? && params[:avoid_repeat_mode].present?
      session[:avoid_repeat_mode] = params[:avoid_repeat_mode] == 'true'
    end

    avoid_repeat_mode = session[:avoid_repeat_mode] == true

    # normalモードへ切り替わった場合は魔法の履歴を使わない
    history = if avoid_repeat_mode && !session[:_switch_complete]
                restore_history(session[:group_history])
              else
                []
              end

    # ========================================
    # GroupAllocator
    # ========================================

    allocator = GroupAllocator.new(
      members: session[:names],
      group_count: session[:group_count],
      history: history
    )

    # ========================================
    # 魔法モードの上限チェック
    # ========================================

    total_possible_pairs = session[:names].length * (session[:names].length - 1) / 2
    if avoid_repeat_mode && history.uniq.length >= total_possible_pairs
      session[:avoid_repeat_mode] = true
      session[:kumiwake_limit_reached] = true
      session.delete(:_switch_complete)

      redirect_to kumiwake_path
      return
    end

    # ========================================
    # 組み分け
    # ========================================

    @groups = allocator.call

    # ========================================
    # 完全に新しい組み合わせを
    # 作れなかった場合
    # ========================================

    if @groups.nil?
      if avoid_repeat_mode
        session[:kumiwake_limit_reached] = true

        redirect_to kumiwake_path
        return
      else
        redirect_to kumiwake_path
        return
      end
    end

    # ========================================
    # 現在の結果を保存
    # ========================================

    session[:current_groups] = compact_groups(@groups)

    # ========================================
    # 抽選回数
    # ========================================

    session[:draw_count] = session[:draw_count].to_i + 1
    session[:round_number] = session[:draw_count].to_i

    # ========================================
    # 過去の結果を保存（履歴用）
    # ========================================

    if avoid_repeat_mode
      past_results = session[:past_results] || []
      past_results << {
        round: session[:round_number],
        groups: compact_groups(@groups),
        round_draw_count: session[:draw_count]
      }
      session[:past_results] = past_results
    end

    # ========================================
    # 魔法モードだけ履歴を保存
    # ========================================

    if avoid_repeat_mode && !session[:_switch_complete]
      @groups.each do |group|
        group.combination(2).each do |member_a, member_b|
          pair = [member_a['id'], member_b['id']].sort

          history << pair unless history.include?(pair)
        end
      end

      session[:group_history] = compact_history(history)
    end

    # normalモード切り替え完了フラグをリセット
    session.delete(:_switch_complete)

    redirect_to kumiwake_result_path
  end

  # ========================================
  # 組み分け結果
  # ========================================

  def result
    last_result = Array(session[:past_results]).compact.last
    stored_groups = session[:current_groups] || last_result&.dig('groups') || last_result&.dig(:groups)
    @groups = restore_groups(stored_groups)

    # 結果がない場合
    unless @groups
      redirect_to kumiwake_path
      return
    end

    @group_names = session[:group_names] || []
    @draw_count = session[:draw_count].to_i
    @draw_count = last_result['round_draw_count'].to_i if @draw_count.zero? && last_result.present?
    @round_number = @draw_count.positive? ? @draw_count : 1

    # 現在のモード
    @avoid_repeat_mode = session[:avoid_repeat_mode] == true
    @past_results = Array(session[:past_results]).compact
    @show_history_button = @avoid_repeat_mode && @past_results.length >= 2
  end

  # ========================================
  # 履歴表示
  # ========================================

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

  # ========================================
  # 組み分けを終了
  # ========================================

  def finish
    clear_round_state
    redirect_to root_path
  end

  private

  def migrate_legacy_mode_key
    return unless session[:avoid_repeat_mode].nil? && !session[:magic_mode].nil?

    session[:avoid_repeat_mode] = session.delete(:magic_mode)
  end

  def compact_groups(groups)
    groups.map do |group|
      group.map { |member| member['id'] || member[:id] }
    end
  end

  def compact_history(history)
    history.map { |member_a, member_b| "#{member_a}:#{member_b}" }
  end

  def restore_history(history)
    Array(history).filter_map do |pair|
      if pair.is_a?(Array)
        pair.map(&:to_i)
      elsif pair.is_a?(String)
        pair.split(':', 2).map(&:to_i) if pair.include?(':')
      end
    end
  end

  # ========================================
  # 魔法の理論上限回数
  # ========================================

  def magic_max_rounds
    GroupAllocator.maximum_rounds(
      member_count: session[:names]&.length.to_i,
      group_count: session[:group_count].to_i
    )
  end
end

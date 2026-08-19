class KumiwakeController < ApplicationController
  def index
    @names = session[:names] || []

    @from_name_input = session.delete(:from_name_input)
    @from_group_name_input = session.delete(:from_group_name_input)

    # 魔法の上限に到達したときだけ true
    # JS が index 画面で上限到達時のセリフを表示するため、ここでは削除しない
    @kumiwake_limit_reached = session[:kumiwake_limit_reached]

    # 現在のモード
    @magic_mode = session[:magic_mode]

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
        "id" => index + 1,
        "name" => name
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
      if name.blank?
        "#{('A'.ord + index).chr}組"
      else
        name
      end
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
    if params[:switch_to_normal] == "true" || params[:normal_mode] == "true" || params[:magic_mode] == "false"
      session[:magic_mode] = false
      session.delete(:group_history)
      session.delete(:kumiwake_limit_reached)
      session[:_switch_complete] = true
    end

    # ========================================
    # 最初の抽選時だけモードを保存
    # ========================================
    #
    # session[:magic_mode] がまだ存在しない場合だけ
    # JSから送られてきた magic_mode を採用する
    #
    if session[:magic_mode].nil? && params[:magic_mode].present?
      session[:magic_mode] = params[:magic_mode] == "true"
    end

    magic_mode = session[:magic_mode] == true

    # normalモードへ切り替わった場合は魔法の履歴を使わない
    history = (magic_mode && !session[:_switch_complete]) ? (session[:group_history] || []) : []

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
    if magic_mode && history.uniq.length >= total_possible_pairs
      session[:magic_mode] = true
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
      if magic_mode
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

    session[:current_groups] = @groups

    # ========================================
    # 抽選回数
    # ========================================

    session[:draw_count] = session[:draw_count].to_i + 1
    session[:round_number] = session[:draw_count].to_i

    # ========================================
    # 過去の結果を保存（履歴用）
    # ========================================

    if magic_mode
      past_results = session[:past_results] || []
      past_results << {
        round: session[:round_number],
        groups: @groups,
        draw_count: session[:draw_count]
      }
      session[:past_results] = past_results
    end

    # ========================================
    # 魔法モードだけ履歴を保存
    # ========================================

    if magic_mode && !session[:_switch_complete]
      @groups.each do |group|
        group.combination(2).each do |member_a, member_b|
          pair = [member_a["id"], member_b["id"]].sort

          history << pair unless history.include?(pair)
        end
      end

      session[:group_history] = history
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
    @groups = session[:current_groups] || last_result&.dig("groups") || last_result&.dig(:groups)

    # 結果がない場合
    unless @groups
      redirect_to kumiwake_path
      return
    end

    @group_names = session[:group_names] || []
    @draw_count = session[:draw_count].to_i
    @draw_count = last_result["draw_count"].to_i if @draw_count.zero? && last_result.present?
    @round_number = @draw_count.positive? ? @draw_count : 1

    # 現在のモード
    @magic_mode = session[:magic_mode] == true
    @past_results = Array(session[:past_results]).compact
    @show_history_button = @magic_mode && @past_results.length >= 2
  end

  # ========================================
  # 履歴表示
  # ========================================

  def history
    @group_names = session[:group_names] || []
    @past_results = Array(session[:past_results]).filter_map do |result|
      next unless result.is_a?(Hash)

      {
        "round" => result["round"] || result[:round],
        "groups" => Array(result["groups"] || result[:groups]),
        "draw_count" => result["draw_count"] || result[:draw_count]
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

  def clear_round_state
    session.delete(:group_history)
    session.delete(:current_groups)
    session.delete(:draw_count)
    session.delete(:round_number)
    session.delete(:past_results)
    session.delete(:kumiwake_limit_reached)
    session.delete(:magic_mode)
    session.delete(:_switch_complete)
  end

  # ========================================
  # 魔法の理論上限回数
  # ========================================

  def magic_max_rounds
    members_count = session[:names]&.length.to_i
    group_count = session[:group_count].to_i

    return 0 if members_count < 2 || group_count < 1

    total_pairs = members_count * (members_count - 1) / 2

    base_size = members_count / group_count
    remainder = members_count % group_count

    pairs_per_round = 0

    group_count.times do |i|
      size = base_size
      size += 1 if i < remainder

      pairs_per_round += size * (size - 1) / 2
    end

    return 0 if pairs_per_round.zero?

    total_pairs / pairs_per_round
  end

end
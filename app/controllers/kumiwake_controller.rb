# frozen_string_literal: true

class KumiwakeController < ApplicationController
  include KumiwakeSessionState
  include KumiwakeResultActions

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

  def input; end

  # ========================================
  # 名簿保存
  # ========================================

  def save_names
    roster = ParticipantRoster.new(params[:names])
    return redirect_to kumiwake_input_path unless roster.valid?

    session[:names] = roster.to_session

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

    group_names = GroupNames.new(params[:group_names]).call

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
    result = KumiwakeDrawer.new(session: session, params: params).call

    if result.drawn?
      redirect_to kumiwake_result_path
    else
      redirect_to kumiwake_path
    end
  end

  # ========================================
  # 組み分けを終了
  # ========================================

  def finish
    clear_round_state
    redirect_to home_index_path
  end

  private

  def migrate_legacy_mode_key
    return unless session[:avoid_repeat_mode].nil? && !session[:magic_mode].nil?

    session[:avoid_repeat_mode] = session.delete(:magic_mode)
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

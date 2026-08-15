class KumiwakeController < ApplicationController
  def index
    @names = session[:names] || []
    @from_name_input = session.delete(:from_name_input)
    @from_group_name_input = session.delete(:from_group_name_input)
  end

  def input
  end

  # 名簿保存用
  def save_names
    names = params[:names].reject(&:blank?)

    # 登録番号付きで保存
    session[:names] = names.each_with_index.map do |name, index|
      {
        "id" => index + 1,
        "name" => name
      }
    end

    # 新しい組み分けを始めるので履歴をリセット
    session.delete(:group_history)
    session.delete(:current_groups)
    session.delete(:draw_count)

    session[:from_name_input] = true

    redirect_to kumiwake_path
  end

  # グループ名保存用
  def save_group_names
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

  # 組名入力画面
  def group_names
    @names = session[:names] || []

    # 最大組数は「名簿人数 - 1」
    @max_group_count = @names.length - 1
  end

  # 組み分け実行
  def draw
    @groups = GroupAllocator.new(
      members: session[:names],
      group_count: session[:group_count],
      history: session[:group_history] || []
    ).call

    # 現在の結果を保存
    session[:current_groups] = @groups

    # 抽選回数を増やす
    session[:draw_count] = session[:draw_count].to_i + 1

    # 今回できたペアを履歴に追加
    history = session[:group_history] || []

    @groups.each do |group|
      group.combination(2).each do |member_a, member_b|
        pair = [member_a["id"], member_b["id"]].sort

        history << pair unless history.include?(pair)
      end
    end

    session[:group_history] = history
    # 結果が表示されたときに履歴として保存

    redirect_to kumiwake_result_path
    
  end

  # 組み分け結果表示
  def result
    @groups = session[:current_groups]

    # まだ組み分けされていない場合
    unless @groups
      redirect_to kumiwake_path
      return
    end

    @group_names = session[:group_names]
    @draw_count = session[:draw_count].to_i
  end
end
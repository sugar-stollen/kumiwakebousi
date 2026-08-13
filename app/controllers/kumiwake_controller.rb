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

    session[:names] = names
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
end
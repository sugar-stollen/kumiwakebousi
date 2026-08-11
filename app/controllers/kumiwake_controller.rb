class KumiwakeController < ApplicationController
  def index
  @names = session[:names] || []
  @from_name_input = session.delete(:from_name_input)
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

  class KumiwakeController < ApplicationController

      def group_names
      end
  end

end

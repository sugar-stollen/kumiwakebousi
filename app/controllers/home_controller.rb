# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @returning_from_kumiwake = params[:returning] == 'true'
  end
end

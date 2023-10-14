class PagesController < ApplicationController
  before_action :authenticate_user!, except: %i[landing]
  before_action :set_user, except: %i[landing]

  def landing

  end

  def recommendations
    get_recommendation_tab
    get_tab_numbers
  end

  private

  def get_tab_numbers
    @tab_1 = Company.one_1.count
    @tab_2 = Company.two_1.count
    @tab_3 = Company.three_1.count
    @tab_4 = Company.four_1.count
    @tab_5 = Company.five_1.count
  end

  def get_recommendation_tab
    if params[:tab].nil?
      tab = 5
    else
      tab = params[:tab].to_i
    end

    if params[:query].nil?
      query = 1
    else
      query = params[:query].to_i
    end

    if query == 1
      case tab
      when 1
        @companies = Company.one_1
      when 2
        @companies = Company.two_1
      when 3
        @companies = Company.three_1
      when 4
        @companies = Company.four_1
      when 5
        @companies = Company.five_1
      end
      @companies
    end
    @tab = tab
  end

  def set_user
    @current_user = current_user
  end
end

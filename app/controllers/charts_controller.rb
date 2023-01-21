class ChartsController < ApplicationController
  before_action :set_company, only: %i[ highs per_move sma ]
  before_action :set_range, only: %i[ highs per_move sma ]

  def highs
    @chart_data = Record.all.where(company: @company).order(date: :asc).last(params[:range]).map { |x| [x.date, x.close] }

  end

  def per_move

  end

  def sma

  end

  private

  def chart_params
    params.require(:company).permit(:company_id, :range)
  end

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_range
    if params[:range].present?
      @range = params[:range].to_i
    else
      @range = 1000
    end
  end

end

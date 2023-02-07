class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, only: %i[ show edit update destroy ]
  before_action :set_user

  # GET /companies or /companies.json
  def index
    if params[:q].nil?
      @companies = Company.all
    else
      @companies = Company.where("name ILIKE ? OR ticker ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%")
    end
  end

  def recommendations
    get_recommendation_tab

  end

  def favorites
    @companies = current_user.companies
  end
  # GET /companies/1 or /companies/1.json
  def show
    set_range
    @sma_data = Record.all.where(company: @company).order(date: :desc).first(params[:range].to_i).map { |x| [x.date, x.close, x.sma_10, x.sma_20, x.sma_30, x.sma_50, x.sma_100, x.sma_200] }
    @per_data = Record.all.where(company: @company).order(date: :desc).first(params[:range].to_i).map { |x| [x.date, x.per_move_10_200, x.per_move_20_200, x.per_move_30_200, x.per_move_50_200, x.per_move_100_200, x.per_move_close_50] }
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies or /companies.json
  def create
    @company = Company.new(company_params)
    @company.new = true
    resource = RestClient::Resource.new("https://query1.finance.yahoo.com/v7/finance/quote?symbols=#{@company.ticker}")
    result = JSON.parse(resource.get)
    if result.dig("quoteResponse", "result", 0, "longName").nil?
      render :new, status: :unprocessable_entity
      return
    end
    @company.name = result.dig("quoteResponse", "result", 0, "longName")


    respond_to do |format|
      if @company.save
        format.html { redirect_to company_url(@company), notice: "Company was successfully created." }
        format.json { render :show, status: :created, location: @company }
        @company.get_records
        Record.calc_sma
        Record.calc_per_move
        @company.update(new: false)
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1 or /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to company_url(@company), notice: "Company was successfully updated." }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  def color



    @company = Company.find(params[:id])

    @company.color_code = params[:color_code]
    @company.save
    redirect_to company_url(@company)
  end

  # DELETE /companies/1 or /companies/1.json
  def destroy
    @company.destroy

    respond_to do |format|
      format.html { redirect_to companies_url, notice: "Company was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:id])
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
    elsif query == 2
      case tab
      when 1
        @companies = Company.one_2
      when 2
        @companies = Company.two_2
      when 3
        @companies = Company.three_2
      when 4
        @companies = Company.four_2
      when 5
        @companies = Company.five_2
      end
      @companies
    end
  end

  def set_user
    @current_user = current_user
  end

  # Only allow a list of trusted parameters through.
  def company_params
    params.require(:company).permit(:name, :ticker, :status, :range, :color_code, :query)
  end

  def set_range
    if params[:range].nil? || params[:range].to_i.zero?
      params[:range] = 1000
    end
  end
end

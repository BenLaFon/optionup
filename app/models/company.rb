class Company < ApplicationRecord
  has_many :records, dependent: :destroy

  has_many :user_favorites
  has_many :users, through: :user_favorites
  validates :ticker, presence: true, uniqueness: true
  enum query_1_status: { zero_1: 0, one_1: 1, two_1: 2, three_1: 3, four_1: 4, five_1: 5 }
  enum query_2_status: { zero_2: 0, one_2: 1, two_2: 2, three_2: 3, four_2: 4, five_2: 5 }
  enum color_code: { gray: 0, green: 1, yellow: 2, red: 3 }
  default_scope -> { order(ticker: :asc) }
  scope :new_companies, -> {where("new = ?", true)}

  def get_records
    #check company status
    if self.status != 0
      puts "#{self.ticker} is not active status"
      return
    end
    # check latest record
    last_record_date = self.records.order(date: :desc).first.date
    if last_record_date == Date.yesterday
      puts "already have records for #{ticker}"
      return
    end

    p "getting records for #{ticker}"
    begin
      # code that might raise an exception
      result = call_alpha_api(ticker)
    rescue ExceptionType => e
      # code to handle the exception
      sleep 60
      result = call_alpha_api(ticker)
    end
    tries = 0
    while result['Note'] || result ['Information']
      p "result had note, sleeping 10"
      sleep 10
      result = call_alpha_api(ticker)
    end

    if result["Error Message"]
      p "result had error message"
      status = 1
      return
    end

    if result['Time Series (Daily)']
      p "going into unpack"
      unpack_records(result, ticker, last_record_date)
    end
  p 'ending '
  end

  def self.set_query_1_status
    # level 1 50_day moving average below 200_day moving average
    p "processing level 1"
    sql = <<~EOS
            SELECT c.*
            FROM companies c
            JOIN (
                SELECT company_id, MAX(date) as max_date
                FROM records
                GROUP BY company_id
            ) r ON c.id = r.company_id
            JOIN records ON records.company_id = c.id and records.date = r.max_date
            WHERE records.sma_50 < records.sma_200;
          EOS

    companies = Company.find_by_sql(sql)
    companies.each do |company|
      company.update(query_1_status: 1)
    end
    p "#{Company.one_1.count} companies are level 1"
    # level 2 closings under 50 day average for at least 45 days
    Company.one_1.each do |company|
      p "#{company.name} processing level 2"
      company.records.order(date: :desc).limit(45).each do |record|
        result = 0
        if record.close >= record.sma_50
          result = 1
        end
        company.update(query_1_status: 2) if result == 0
      end
    end
    p "#{Company.two_1.count} companies are level 2"
    # level 3 per_move_close_50 is in the lowest 80th percentile
    p "processing level 3"
    Company.two_1.each do |company|

      p"#{company} processing level 3"
      if company.records.order(date: :desc).limit(1)[0]["per_move_close_50"].negative?
        company.update(query_1_status: 3)
      end
    end
    p "#{Company.three_1.count} companies are level 3"
    # level 4 the latest close is below the highest point in the window by at least 35%
    p "processing level 4"
    Company.three_1.each do |company|
      high = 0
      index = 0

      records = company.records.order(date: :desc)
      while records[index]["close"].to_f <= records[index]["sma_50"].to_f
        if records[index]["close"].to_f > high
          high = records[index]["close"].to_f
        end
        index += 1

      end

      adj_high = high * 0.75
      company.update(query_1_status: 4) if company.records.order(date: :desc).limit(1)[0]["close"].to_f <= adj_high.to_f

      p "#{company.name} processed level 4"
    end
    p "#{Company.four_1.count} companies are level 4"
    # level 5 the ten day average is grater than the 20 day avg
    Company.four_1.each do |company|
      company.update(query_1_status: 5) if company.records.order(date: :desc).limit(1)[0]["sma_10"].to_f >= company.records.order(date: :desc).limit(10)[0]["sma_20"].to_f
    end
    p "#{Company.five_1.count} companies are level 5"
  end


  # def self.set_query_2_status
  #   # seveny percentile
  #   p "running set_query_2_status, setting 70th percentile"
  #   Company.calc_seventy_percentile
  #   Company.two_1.each do |company|

  #     p"#{company} processing level 3_2"
  #     if company.records.order(date: :desc).limit(1)[0]["per_move_close_50"].to_f <= company.seventy_percentile.to_f
  #       company.update(query_2_status: 3)
  #     end
  #   end
  #   p "#{Company.three_2.count} companies are level 3"
  #   # level 4 the latest close is below the highest point in the window by at least 35%
  #   p "processing level 4"
  #   Company.three_2.each do |company|
  #     high = 0
  #     index = 0

  #     records = company.records.order(date: :desc)
  #     while records[index]["close"].to_f <= records[index]["sma_50"].to_f
  #       if records[index]["close"].to_f > high
  #         high = records[index]["close"].to_f
  #       end
  #       index += 1
  #     end
  #     # high less than 20%
  #     high = high * 0.20
  #     company.update(query_2_status: 4) if company.records.order(date: :desc).limit(1)[0]["close"].to_f <= high.to_f

  #     p "#{company.name} processed level 4"
  #   end
  #   p "#{Company.four_2.count} companies are level 4"
  #   # level 5 the ten day average is grater than the 20 day avg
  #   Company.four_2.each do |company|
  #     company.update(query_2_status: 5) if company.records.order(date: :desc).limit(1)[0]["sma_10"].to_f >= company.records.order(date: :desc).limit(10)[0]["sma_20"].to_f
  #   end
  #   p "#{Company.five_2.count} companies are level 5"
  # end

  def self.calc_eighty_percentile
    Company.all.each do |company|
    a = company.records.pluck(:per_move_close_50).sort
    company.eighty_percentile = a[0.8 * a.count]
    company.save
    end
  end

  def self.calc_seventy_percentile
    Company.all.each do |company|
    a = company.records.pluck(:per_move_close_50).sort
    company.seventy_percentile = a[0.7 * a.count]
    company.save
    end
  end


  # Running level 2-a query needs to find way to organize queries better
  def self.calc_level_two
    Company.two.each do |company|
      company.update(level_two: true) if company.records.order(date: :desc).limit(1)[0]["sma_10"].to_f >= company.records.order(date: :desc).limit(10)[0]["sma_20"].to_f
    end
  end

  def update_new_companies
    Record.calc_sma
    Record.calc_per_move
    Company.new_companies.each do |company|
      company.update(new: false)
    end
  end





  private

  def unpack_records(result, ticker, last_record_date)

    puts "unpacking records for #{ticker}"
    # puts result
    count = 0

    result['Time Series (Daily)'].each do |date, data|
      if Date.parse(date) < last_record_date
        puts "cutting off #{ticker} at #{date}"
        return
      end
      record = Record.new
      record.company = Company.find_by(ticker: ticker)
      record.date = Date.parse(date)
      record.high = data['2. high'].to_f
      record.low = data['3. low'].to_f
      record.open = data['1. open'].to_f
      record.close = data['4. close'].to_f
      record.volume = data['5. volume'].to_i
      if record.save
        count += 1
        puts "saved #{count} records for #{ticker}"
      else
        puts "record not saved for #{ticker}"
      end
    end
  end

  def call_yahoo_api
    p "getting records for #{ticker}"
    resource = RestClient::Resource.new(
      "https://query1.finance.yahoo.com/v8/finance/chart/#{ticker}?interval=1d&range=#{range}",
      :timeout => nil,
      :open_timeout => nil
    )
    retries = 5
    begin

      info = JSON.parse(resource.get)
      p "got info for #{ticker}"
      return info

    rescue => e
      if retries.positive?
        p"retrying #{ticker} #{retries} times"
        retries -= 1
        sleep 1
        retry
      else
        x = Error.create(company: self, message: e.message)
        p "created error id:#{x.id} with message:#{x.message} created"
        return nil
      end
    end

  end

  def call_alpha_api(ticker = self.ticker)
    url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=#{ticker}&apikey=#{Rails.application.credentials.alpha_vantage.api_key}&outputsize=compact"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    result = JSON.parse(response)
    return result
  end

  def range

    if self.records.count == 0
      return "10y"
    else
      range = (Date.today - set_latest_date.to_date).to_i
    end

    if range <= 5
      "5d"
    elsif range <= 30
      "1mo"
    elsif range <= 90
      "3mo"
    elsif range <= 180
      "6mo"
    elsif range <= 365
      "1y"
    elsif range <= 730
      "2y"
    elsif range <= 1825
      "5y"
    elsif range <= 365000
      "10y"
    end
  end


  def set_latest_date
    self.records.maximum(:date)
  end

end

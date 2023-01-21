class Company < ApplicationRecord
  has_many :records
  has_many :user_favorites
  has_many :users, through: :user_favorites
  validates :ticker, presence: true, uniqueness: true
  enum query_1_status: { zero: 0, one: 1, two: 2, three: 3, four: 4, five: 5 }

  def get_records

    result = call_yahoo_api

    if result.nil?
      x = Error.create(company: self, message: "no records for #{ticker}, was returned nil")
      p "no records for #{ticker} created error id:#{x.id} with message:#{x.message}"
      return
    end

    highs = result.dig('chart', 'result', 0, 'indicators', 'quote', 0, 'high')
    unpack_records(result, highs)
    p "finished getting records for #{ticker}"

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
    p "#{Company.one.count} companies are level 1"
    # level 2 closings under 50 day average for at least 45 days
    Company.one.each do |company|
      p "#{company.name} processing level 2"
      company.records.order(date: :desc).limit(45).each do |record|
        result = 0
        if record.close >= record.sma_50
          result = 1
        end
        company.update(query_1_status: 2) if result == 0
      end
    end
    p "#{Company.two.count} companies are level 2"
    # level 3 per_move_close_50 is in the lowest 80th percentile
    p "processing level 3"
    Company.two.each do |company|

      p"#{company} processing level 3"
      if company.records.order(date: :desc).limit(1)[0]["per_move_close_50"].to_f <= company.eighty_percentile.to_i
        company.update(query_1_status: 3)
      end
    end
    p "#{Company.three.count} companies are level 3"
    # level 4 the latest close is below the highest point in the window by at least 35%
    p "processing level 4"
    Company.three.each do |company|
      high = 0
      index = 0

      records = company.records.order(date: :desc)
      while records[index]["close"].to_f <= records[index]["sma_50"].to_f
        if records[index]["close"].to_f > high
          high = records[index]["close"].to_f
        end
        index += 1

      end



      high = high * 0.65
      company.update(query_1_status: 4) if company.records.order(date: :desc).limit(1)[0]["close"].to_f <= high.to_f

      p "#{company.name} processed level 4"


    end
    p "#{Company.four.count} companies are level 4"
    # level 5 the ten day average is grater than the 20 day avg
    Company.four.each do |company|
      company.update(query_1_status: 5) if company.records.order(date: :desc).limit(1)[0]["sma_10"].to_f >= company.records.order(date: :desc).limit(10)[0]["sma_20"].to_f
    end
    p "#{Company.five.count} companies are level 5"
  end

  def self.calc_eighty_percentile
    Company.all.each do |company|
    a = company.records.pluck(:per_move_close_50).sort
    company.eighty_percentile = a[0.2 * a.count]
    company.save
  end
end

  private

  def unpack_records(result, highs)
    count = 0
    highs.each_with_index do |high, index|
      record = Record.new
      record.company = Company.find_by(ticker: ticker)
      record.date = Time.at(result.dig('chart', 'result', 0, 'timestamp', index)).to_date
      record.high = result.dig('chart', 'result', 0, 'indicators', 'quote', 0, 'high', index)
      record.low = result.dig('chart', 'result', 0, 'indicators', 'quote', 0, 'low', index)
      record.open = result.dig('chart', 'result', 0, 'indicators', 'quote', 0, 'open', index)
      record.close = result.dig('chart', 'result', 0, 'indicators', 'quote', 0, 'close', index)
      record.volume = result.dig('chart', 'result', 0, 'indicators', 'quote', 0, 'volume', index)
      if record.save
        count += 1
        "saved #{count} records for #{ticker}"
      else
        p "record not saved for #{ticker}"
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

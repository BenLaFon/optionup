class Company < ApplicationRecord
  has_many :records
  validates :ticker, presence: true, uniqueness: true


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

namespace :update do
  desc "Update records"
  task records: :environment do
    Company.all.each do |company|
      company.get_records
    end
    Record.calc_sma
    Record.calc_per_move
    Company.set_query_1_status
  end

  task status: :environment do
    Company.set_query_1_status
  end

  task new_companies: :environment do
    Company.new_companies.each do |c|
      p c.ticker
      c.get_records
      resource = RestClient::Resource.new("https://query1.finance.yahoo.com/v7/finance/quote?symbols=#{c.ticker}")
      result = JSON.parse(resource.get)
      c.name = result.dig("quoteResponse", "result", 0, "longName")
      c.save
    end
  end

end

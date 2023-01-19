require 'csv'

namespace :injest do
  desc "Reads CSV files and creates records in the database"
  task companies: :environment do
    CSV_PATH = "test_tickers.csv"
    companies = []
    CSV.foreach(CSV_PATH, headers: true) do |row|
      company = Hash.new
      ticker = row['Symbol'].strip
      ticker.gsub!("/", "-") if ticker.include?("/")
      company[:ticker] = ticker
      row['Industry'].present? ? company[:industry] = row['Industry'] : company[:industry] = "N/A"
      row['Sector'].present? ? company[:sector] = row['Sector'] : company[:sector] = "N/A"
      company[:name] = row['Name'] if row['Name'].present?
      p "------"

      companies << company
      p "company #{company[:name]} added"
    end
    Company.import(companies)

  end

  desc "Calls Yahoo Finance API and creates records in the database"
  task records: :environment do
    Company.all.each do |company|
      company.get_records
    end
  end

  desc "Runs calculations on records for sma's"
  task calculation_1: :environment do
  end

  desc "Runs calculations on records for per_move's"
  task calculation_2: :environment do
  end

end

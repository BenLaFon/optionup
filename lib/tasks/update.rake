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

end

namespace :update do
  desc "Update records"
  task update_records: :environment do
    Company.all.each do |company|
      company.get_records
    end
  end


end

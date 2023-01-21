namespace :query do
  desc "Run Query 1 and set status"
  task set_query_status_to_0: :environment do
    Company.update_all(query_status: 0)
  end
end

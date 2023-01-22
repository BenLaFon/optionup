# env :GEM_PATH, ENV['GEM_PATH']

set :output, "cron_log.log"
# set :bundle_command, "/Users/ben/.rbenv/shims/bundle exec"
every 1.minute do
  rake "test:test"
end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
# every 1.day, at: '4:30 am' do
#    rake "update:records"
# end

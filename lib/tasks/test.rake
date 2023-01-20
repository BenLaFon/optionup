namespace :test do
  desc "Test rake task"
  task :test => :environment do
    puts "hello world"
  end
end

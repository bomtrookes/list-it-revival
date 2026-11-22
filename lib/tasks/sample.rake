namespace :sample do
  desc "Load the sample community from the original project (skips if it's already there; safe to re-run)"
  task load: :environment do
    if SampleCommunity.loaded?
      puts "The sample community is already loaded."
    else
      puts "Loading the sample community (downloads images, takes a few minutes)..."
      attempts = 0
      begin
        attempts += 1
        SampleCommunity.load!
      rescue ActiveRecord::Deadlocked
        raise if attempts >= 3
        puts "Database was busy, trying again (attempt #{attempts + 1} of 3)..."
        sleep 5
        retry
      end
      DemoAccount.reset! if DemoAccount.user
      puts "Done: #{User.where(sample: true).count} sample users, #{List.count} lists."
    end
  end
end

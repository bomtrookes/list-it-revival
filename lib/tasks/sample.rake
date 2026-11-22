namespace :sample do
  desc "Load the sample community from the original project (skips if it's already there)"
  task load: :environment do
    if SampleCommunity.loaded?
      puts "The sample community is already loaded."
    else
      puts "Loading the sample community (downloads images, takes a few minutes)..."
      SampleCommunity.load!
      DemoAccount.reset! if DemoAccount.user # so the demo follows the new users
      puts "Done: #{User.where(sample: true).count} sample users, #{List.count} lists."
    end
  end
end

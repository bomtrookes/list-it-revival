namespace :demo do
  desc "Reset the shared demo account back to its starter content"
  task reset: :environment do
    demo = DemoAccount.reset!
    puts "Demo account @#{demo.username} reset (#{demo.lists.count} lists, following #{demo.followings.count})."
  end
end

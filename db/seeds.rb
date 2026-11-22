# Seeds are safe to run more than once.
#
#   bin/rails db:seed                  # first run: sample community + admin + demo account
#   SEED_RESET=1 bin/rails db:seed     # wipe EVERYTHING and start again (careful in production!)
#
# Admin login comes from ADMIN_EMAIL / ADMIN_PASSWORD (and optional ADMIN_USERNAME, default "bomtrookes").
# In development these default to admin@example.com / password123.

if ENV["SEED_RESET"] == "1"
  puts "Wiping database..."
  [Vote, FavouriteList, Follow, Item, List, ActsAsTaggableOn::Tagging, User].each(&:delete_all)
  ActiveStorage::Attachment.all.each(&:purge)
end

if SampleCommunity.loaded?
  puts "The sample community is already loaded."
else
  puts "Loading the sample community (this downloads images and can take a few minutes)..."
  SampleCommunity.load!
end

admin_email = ENV["ADMIN_EMAIL"].presence || (Rails.env.production? ? nil : "admin@example.com")
admin_password = ENV["ADMIN_PASSWORD"].presence || (Rails.env.production? ? nil : "password123")
if admin_email && admin_password
  username = ENV.fetch("ADMIN_USERNAME", "bomtrookes")
  admin = User.find_by(email: admin_email) || User.find_or_initialize_by(username: username)
  admin.assign_attributes(email: admin_email, password: admin_password, admin: true, demo: false, sample: false)
  admin.username = username if admin.new_record?
  admin.save!
  puts "Admin @#{admin.username} <#{admin.email}> is ready."
else
  puts "No ADMIN_EMAIL / ADMIN_PASSWORD set, so no admin was created. Run bin/rails admin:create later."
end

demo = DemoAccount.reset!
puts "Demo account @#{demo.username} is ready."

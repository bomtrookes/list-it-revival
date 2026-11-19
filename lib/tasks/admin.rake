namespace :admin do
  desc "Create or update an admin login. Usage: bin/rails admin:create EMAIL=me@example.com PASSWORD=secret [USERNAME=bomtrookes]"
  task create: :environment do
    email = ENV.fetch("EMAIL") { abort "Set EMAIL=..." }
    password = ENV.fetch("PASSWORD") { abort "Set PASSWORD=..." }
    username = ENV.fetch("USERNAME", "bomtrookes")

    user = User.find_by(email: email) || User.find_or_initialize_by(username: username)
    user.assign_attributes(email: email, password: password, admin: true, demo: false, sample: false)
    user.username = username if user.new_record?
    user.save!
    puts "Admin @#{user.username} <#{user.email}> is ready."
  end
end

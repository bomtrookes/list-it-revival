ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # Rails 8 loads routes lazily; Devise needs its mappings before sign_in
  setup { Rails.application.try(:reload_routes_unless_loaded) }

  def create_user(admin: false, **attrs)
    n = SecureRandom.hex(4)
    User.create!({ username: "user#{n}", email: "user#{n}@example.com", password: "password123", admin: admin }.merge(attrs))
  end
end

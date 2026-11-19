require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"

Bundler.require(*Rails.groups)

module ListIt
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])

    config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.test_framework :test_unit, fixture: false
    end

    # Image storage: Cloudinary when CLOUDINARY_URL is set, otherwise local disk
    # (mount /rails/storage as a Docker volume in production).
    config.active_storage.service = ENV["CLOUDINARY_URL"].present? ? :cloudinary : :local
  end
end

source "https://rubygems.org"

ruby "~> 3.3"

gem "rails", "~> 8.1.4"
gem "pg", "~> 1.5"
gem "puma", ">= 6.0"
gem "propshaft"
gem "jsbundling-rails"
gem "cssbundling-rails"
gem "jbuilder"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[windows jruby]

# Auth
gem "devise", "~> 4.9"

# Forms
gem "simple_form", "~> 5.3"

# Tags & search
gem "acts-as-taggable-on", "~> 13.0"
gem "pg_search", "~> 2.3"

# Images (Active Storage). Cloudinary is optional: used only when CLOUDINARY_URL is set.
gem "image_processing", "~> 1.13"
gem "cloudinary", "~> 2.0"


# Seeds
gem "faker"

group :development, :test do
  gem "debug", platforms: %i[mri windows]
  gem "dotenv-rails"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

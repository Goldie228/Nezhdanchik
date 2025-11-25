source "https://rubygems.org"


gem "rails", "~> 7.2.2", ">= 7.2.2.1"

gem "sprockets-rails"

gem "pg", "~> 1.1"

gem "puma", ">= 5.0"

gem "importmap-rails"

gem "turbo-rails"

gem "stimulus-rails"

gem "jbuilder"

gem "redis", ">= 4.0.1"

gem "bcrypt", "~> 3.1.7"

gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "bootsnap", require: false

gem "image_processing", "~> 1.2"

gem "tailwindcss-rails", "~> 4.4"

gem "avo", ">= 3.2"

gem "active_storage_validations"

gem "pundit", "~> 2.5"

gem "devise", "~> 4.9"

gem "leaflet-rails", "~> 1.9"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  gem "brakeman", require: false

  gem "rubocop-rails-omakase", require: false

  gem "dotenv-rails"

  gem "annotate"

  gem "rails-erd"

  gem "rspec-rails", "~> 6.1.1"
  gem "factory_bot_rails", "~> 6.5.1"
  gem "faker", "~> 3.2.1"
  gem "shoulda-matchers", "~> 5.3.0"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "database_cleaner-active_record"
  gem "selenium-webdriver"
  gem "rails-controller-testing"
end

gem "connection_pool", "~> 2.5"

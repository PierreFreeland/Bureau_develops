# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 5.2.0"

# Use Puma as the app server
gem "puma", "~> 3.7"
# Use SCSS for stylesheets
gem "sass-rails", "~> 5.0"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"

gem "compass-rails", github: "Compass/compass-rails"
gem "chosen-rails", "~> 1.8.2"

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery for javascript framework
gem "jquery-rails", "~> 4.3"

# Use CoffeeScript for .coffee assets and views
gem "coffee-rails", "~> 4.2"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Speed up assets generation by compiling on all cores
gem "turbo-sprockets-rails5"

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem "dalli", "~> 2.7.7"
gem "sidekiq"

# Monitoring
gem "rollbar"
gem "newrelic_rpm"
gem "fast_excel", "~> 0.3.0"

# Logging
gem 'lograge'
gem 'lograge-sql' # required to export SQL queries into lograge produced logs
gem 'logstash-event'

# update cron jobs
gem 'whenever', '~> 1.0.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", "~> 2.13"
  gem "selenium-webdriver"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring", "2.1.1"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "letter_opener", "~> 1.6.0"
end

group :test do
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem "chromedriver-helper"
  gem "ffaker"

  gem "minitest-rails"
  gem "minitest-reporters"
  gem "minitest-bang", require: false

  gem "guard"
  gem "guard-minitest"

  gem "minitest-ci"

  gem "rubyXL"

  gem "timecop"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Use config gem to manage environment specific settings.
gem "config", "~> 1.4"

# Authenticator gems
gem "devise", "~> 4.3"
gem "devise_cas_authenticatable", "~> 1.10"

gem "rubyzip", ">= 1.2.1"
gem "axlsx", git: "https://github.com/randym/axlsx.git", ref: "c8ac844"
gem "axlsx_rails"

gem "jquery-ui-rails"

gem "money"

gem "carrierwave", "~> 1.2.3"
gem "fog-aws"

gem "rails-i18n", "~> 5.1"

# string functions (to_ascii)
gem "stringex"

gem "faraday"
gem "faraday_middleware"
gem "faraday-detailed_logger"

gem "custom_error_message"

gem "parallel"
gem "ruby-progressbar"

# Use mailjet for mail delivery in production
gem "mailjet"

# ITG-Hub-goxygene engine
gem "goxygene", path: "vendor/engines/goxygene"

# ITG-Hub-bureau-consultant engine
gem "bureau_consultant", path: "vendor/engines/bureau_consultant"

# ITG-Hub-bureau-soustraitant engine
gem "bureau_soustraitant", path: "vendor/engines/bureau_soustraitant"

# ITG-Hub-Fiches-Services engine
gem "fiches_services", path: "vendor/engines/fiches_services"

# ITG-Hub-LegacyApi engine
gem "api", path: "vendor/engines/api"

source "https://gems.itg.fr/private" do
  gem "novapost"
  gem "base_presenter"
  gem "api_accountancy"
  gem "api_payroll"
  gem "itg_presenter", "~> 0.6.0"
  gem "advance_presenter", "~> 0.0.3"
  # gem "invoice_presenter", '~> 0.0.14'
  # gem "consultant_presenter", '~> 0.10.0'
  # gem "statement_of_activities_presenter", '~> 0.0.17'
  # gem "statement_of_operating_expenses_presenter", '~> 0.0.8'
  # gem "commercial_contract_presenter", '~> 0.24.0'
  gem "commercial_contract_service", "~> 0.26.0"
  gem "invoice_service", "~> 0.7.0"
  gem "annexe_service", "~> 0.7.0"
  gem "cfonb120-parser", "~> 0.1.4"
  gem "cfonb120-processor", "~> 0.1.2"
end

# fancy console
gem 'pry-rails'

# help to kill N+1 queries and unused eager loading
gem "bullet", "~> 7.0", group: 'development'

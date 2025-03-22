# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.4.1'

gem 'brakeman'
gem 'bundler-audit'
gem 'factory_bot_rails'
gem 'faker'
gem 'fugit'
gem 'fuzzy_match'
gem 'geocoder'
gem 'importmap-rails'
gem 'jbuilder'
gem 'net-pop', github: 'ruby/net-pop'
gem 'nokogiri'
gem 'pg'
gem 'pry'
gem 'puma'
gem 'rack'
gem 'rails', '8.0.0.1'
gem 'rdoc'
gem 'rest-client'
gem 'rexml'
gem 'rspec'
gem 'rspec-rails'
gem 'rubocop'
gem 'rubocop-rspec', require: false
gem 'shadcn-ui', '~> 0.0.15'
gem 'simplecov-cobertura'
gem 'solid_queue'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'strong_migrations'
gem 'tailwindcss-rails', '~> 2.7'
gem 'turbo-rails'
gem 'webrick'
# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false
gem 'passenger'

########################
### Security pinning ###
# himom
########################

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows]
end

group :development do
  gem 'capistrano'
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rbenv'
  gem 'capistrano-passenger'
  gem 'capistrano3-puma', github: "seuros/capistrano-puma"

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 6.0'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'webmock'
end

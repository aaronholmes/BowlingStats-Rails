source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'bootstrap-sass'
gem 'yui-rails'
#TODO: Try to remove jquery dependency for bootstrap
gem 'jquery-rails'
gem 'rake'
gem 'bcrypt-ruby', '~> 3.0.1'
gem 'cloudfiles'
gem 'colored'

gem 'activesupport'
gem 'i18n'

gem 'coveralls', require: false

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem "pry"
  gem 'unicorn'
  gem 'bullet'
  gem 'rack-mini-profiler'
end

group :test do
  gem 'capybara', '1.1.2'
  gem 'factory_girl_rails'
end

group :production do
  gem 'pg', '0.12.2'
  gem 'unicorn'
end

group :development do
  gem 'annotate', '~> 2.4.1.beta'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem "asset_sync"
end
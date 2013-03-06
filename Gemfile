source 'https://rubygems.org'

gem 'rails', '3.2.12'
gem 'unicorn', '4.3.1'

gem 'epdq', :git => "https://github.com/alphagov/epdq.git"

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', '3.12.0'
end

gem 'plek', '1.3.1'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'govuk_frontend_toolkit', '0.10.0'
  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'rspec-rails', '2.12.0'
  gem 'capybara', '1.1'
  gem 'simplecov-rcov', '0.2.3'
  gem 'webmock', '1.9.0', :require => false
end

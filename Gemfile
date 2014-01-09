source 'https://rubygems.org'
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'rails', '3.2.16'
gem 'unicorn', '4.3.1'

gem 'epdq', :git => "https://github.com/alphagov/epdq.git", :branch => "gds_master"

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', '3.25.0'
end

gem 'plek', '1.5.0'
gem 'gds-api-adapters', '7.18.0'

gem 'exception_notification', "3.0.1"
gem 'aws-ses', :require => 'aws/ses' # Needed by exception_notification

gem 'logstasher', '0.4.1'

group :assets do
  gem 'govuk_frontend_toolkit', '0.32.2'

  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'rspec-rails', '2.12.0'
  gem 'capybara', '1.1'
  gem 'ci_reporter'
  gem 'simplecov-rcov', '0.2.3'
  gem 'webmock', '1.9.0', :require => false
end

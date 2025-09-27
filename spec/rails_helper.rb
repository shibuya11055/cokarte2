ENV["RAILS_ENV"] ||= 'test'
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# Keep test DB schema up to date
ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

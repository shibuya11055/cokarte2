require 'devise'
require 'warden'

RSpec.configure do |config|
# request spec では Warden のヘルパーでサインインするのが安定
  config.include Warden::Test::Helpers, type: :request
  config.after(type: :request) { Warden.test_reset! }

  # Keep also Devise integration helpers available if needed
  config.include Devise::Test::IntegrationHelpers, type: :request
end

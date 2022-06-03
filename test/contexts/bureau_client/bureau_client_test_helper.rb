ENV['RAILS_ENV']   ||= 'test'

require_relative '../../../config/environment'
require 'rails/test_help'

if ActionPack::VERSION::STRING >= "5.2.0"
  Minitest::Rails::TestUnit ||= Rails::TestUnit
end

module Doorkeeper
  class Application
    belongs_to :user, class_name: 'Goxygene::Employee', foreign_key: 'user_id'
  end
end

class ActiveSupport::BureauClientIntegrationTest < ActionDispatch::IntegrationTest
  self.fixture_path = "#{Rails.root}/test/contexts/bureau_client/fixtures/"

  set_fixture_class(
    oauth_access_tokens: Doorkeeper::AccessToken,
    oauth_applications: Doorkeeper::Application,
  )
  self.use_transactional_tests = false

  fixtures :all

  setup do
    travel_to(Time.zone.local(2018, 12, 19, 20, 45, 0))
    freeze_time
  end

  def authorization_header
    { "Authorization": "Bearer #{oauth_access_tokens(:api_tests).token}" }
  end

end

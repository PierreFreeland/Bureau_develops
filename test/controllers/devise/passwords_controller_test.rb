require 'test_helper'

describe Devise::PasswordsController do

  describe 'with a consultant' do
    let(:reset_password_token) {
      Devise.token_generator.generate(CasAuthentication, :reset_password_token)
    }

    it 'redirects to the cas auth page' do
      post '/cas_authentications/password', params: {
        cas_authentication: {
          login: 'Liane.Bahringer_13894@consulting-itg.fr'
        }
      }

      assert_response :redirect
    end

    it 'does not fail if consultant does not have a consultant_services entry' do
      consultant = CasAuthentication.find_by(login: 'Liane.Bahringer_13894@consulting-itg.fr')
      consultant.update_columns reset_password_token: reset_password_token.last,
                                reset_password_send_at: Time.now

      put '/cas_authentications/password', params: {
        cas_authentication: {
          reset_password_token: reset_password_token.first,
          password: '12345abcd',
          password_confirmation: '12345abcd'
        }
      }

      assert_response :redirect
    end
  end

end

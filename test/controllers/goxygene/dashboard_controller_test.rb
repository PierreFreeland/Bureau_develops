require 'test_helper'

describe 'Goxygene::DashboardController' do
  describe 'authenticated as a prospect' do
    before { sign_in cas_authentications(:future_prospect) }

    it 'redirects to the bureau prospect' do
      get '/goxygene/'

      assert_redirected_to 'https://bureau-prospect.itg.fr'
    end
  end

  describe 'authenticated as a consultant' do
    before { sign_in cas_authentications(:jackie_denesik) }

    it 'redirects to the bureau consultant' do
      get '/goxygene/'

      assert_redirected_to '/bureau_consultant/'
    end
  end

  describe 'authenticated as an administrator' do
    before do
      sign_in cas_authentications(:administrator)
    end

    it 'displays the home page' do
      get '/goxygene/dashboard'
      assert_response :success
    end
  end

  describe 'not authenticated' do
    it 'redirects to the authentication page' do
      get '/goxygene/dashboard'
      assert_redirected_to '/cas_authentications/sign_in'
    end
  end
end

require 'test_helper'

describe BureauConsultant::HelpController do
  describe 'authenticated as a consultant' do
    before do
      sign_in cas_authentications(:jackie_denesik)
    end

    it 'displays categories' do
      get "/bureau_consultant/help"
      assert_response :success
    end

  end

  describe 'not authenticated' do
    it 'redirects to the authentication page when listing categories' do
      get "/bureau_consultant/help"
      assert_redirected_to '/cas_authentications/sign_in'
    end
  end
end

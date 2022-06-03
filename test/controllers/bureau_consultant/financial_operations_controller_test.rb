require 'test_helper'

describe 'BureauConsultant::FinancialOperationsController' do
  describe 'authenticated as a consultant' do
    before do
      sign_in cas_authentications(:jackie_denesik)
    end

    it 'renders the page' do
      get '/bureau_consultant/financial_operations'
      assert_response :success
    end
  end

  describe 'not authenticated' do
    it 'redirects to the authentication page' do
      get '/bureau_consultant/financial_operations'
      assert_redirected_to '/cas_authentications/sign_in'
    end
  end
end

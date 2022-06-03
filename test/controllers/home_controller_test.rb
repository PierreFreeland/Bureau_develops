require 'test_helper'

describe 'HomeController' do
  describe 'authenticated as a prospect' do
    before { sign_in cas_authentications(:future_prospect) }

    it 'redirects to the bureau prospect' do
      get '/'

      assert_redirected_to 'https://bureau-prospect.itg.fr'
    end
  end

  describe 'authenticated as a consultant' do
    before { sign_in cas_authentications(:jackie_denesik) }

    it 'redirects to the bureau consultant' do
      get '/'

      assert_redirected_to '/bureau_consultant/'
    end
  end

  describe 'not authenticated' do
    it 'redirects to the authentication page' do
      get '/'
      assert_redirected_to '/cas_authentications/sign_in'
    end
  end
end

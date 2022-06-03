require 'test_helper'

describe BureauConsultant::ContactsController do
  describe 'authenticated as a consultant' do
    before { sign_in cas_authentications(:jackie_denesik) }

    describe 'on the index page' do
      it 'renders the page' do
        get '/bureau_consultant/contacts'
        assert_response :success
      end
    end

    describe 'on a mobile' do
      describe 'on the index page' do
        it 'renders the page' do
          get '/m/bureau_consultant/contacts'
          assert_response :success
        end
      end
    end
  end

  describe 'not authenticated' do

    describe 'on the index page' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/contacts'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end

  end
end

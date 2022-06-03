require 'test_helper'

describe BureauConsultant::CommercialActivitiesController do
  describe 'authenticated as a consultant' do
    before do
      sign_in cas_authentications(:jackie_denesik)
    end

    describe 'in the index action' do
      before { get "/bureau_consultant/commercial_activities" }

      it 'render the page' do
        assert_response :success
      end

      it "includes a button to create a new training contract" do
        assert_select "a.btn", "CRÉER UN NOUVEAU CONTRAT"
      end

      it 'includes a link for the signed training contracts' do
        assert_select 'a', "Historique de mes conventions signées >"
      end

      it 'includes a link for the office training contracts' do
        assert_select 'a', "Historique de mes demandes de conventions >"
      end
    end

  end

  describe 'not authenticated' do
    it 'redirects to the authentication page when listing categories' do
      get "/bureau_consultant/commercial_activities"
      assert_redirected_to '/cas_authentications/sign_in'
    end
  end
end

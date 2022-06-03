require 'test_helper'

describe BureauConsultant::ServicesController do
    describe "authenticated as a consultant" do
      let(:consultant) { Goxygene::Consultant.find 9392 }
  
      before do
        sign_in cas_authentications(:jackie_denesik)
      end

    describe "BU name" do
        it "business unit name" do
          get "/bureau_consultant/home"
          assert_response :success
        end
        
        it "business unit name" do
          get "/bureau_consultant/services"
          assert_select "div.group-name", "Le Plan Epargne Entreprise #{Goxygene::Parameter.value_for_group}"
        end
      end
    end
end
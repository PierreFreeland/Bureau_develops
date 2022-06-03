# frozen_string_literal: true

require "test_helper"

describe BureauSoustraitant::HomeController do
  describe "authenticated as a subcontractor" do

    before do
      sign_in cas_authentications(:subcontractor_1)
    end

    it "displays the home page" do
      get "/bureau_soustraitant/home"
      assert_response :success
    end
  end

  describe "authenticated as a prospect" do

    before do
      sign_in cas_authentications(:subcontractor_prospect_2)
    end

    it "displays the documents page as the default page" do
      get "/bureau_soustraitant/documents"
      assert_response :success
    end
  end

  describe "not authenticated" do
    it "redirects to the authentication page" do
      get "/bureau_soustraitant/home"
      assert_redirected_to "/cas_authentications/sign_in"
    end
  end
end

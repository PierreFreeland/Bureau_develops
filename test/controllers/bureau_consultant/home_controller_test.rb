# frozen_string_literal: true

require "test_helper"

describe BureauConsultant::HomeController do
  describe 'authenticated as a prospect' do
    before { sign_in cas_authentications(:future_prospect) }

    it 'redirects to the bureau prospect' do
      get '/bureau_consultant/home'

      assert_redirected_to 'https://bureau-prospect.itg.fr'
    end
  end

  describe "authenticated as a consultant" do
    let(:consultant) { Goxygene::Consultant.find 9392 }

    before do
      sign_in cas_authentications(:jackie_denesik)
    end

    describe "on a mobile" do
      it "displays the home page" do
        get "/m/bureau_consultant/home"
        assert_response :success
      end
    end

    it "displays the home page" do
      get "/bureau_consultant/home"
      assert_response :success
    end

    it "fetches the last 3 articles"

    it "fetches the rss feed" do
      get "/bureau_consultant/home"
      assert_select "div.actus-feeds a div.actus-boxes"
    end

    describe "for the google_analytics_id" do
      describe "when the consultant does not have one" do
        before do
          consultant.update! google_analytics_code: nil
          sign_in CasAuthentication.find_by(cas_user_id: consultant.id)
        end

        it "creates the google_analytics_id in database" do
          get "/bureau_consultant/home"

          assert_not_nil consultant.reload.google_analytics_code
        end

        it "renders the newly created google_analytics_id in the page" do
          get "/bureau_consultant/home"

          assert response.body.match(/'userId' : '#{consultant.reload.google_analytics_code}'/)
        end
      end

      describe "when the consultant already have one" do
        it "does not change the entry in database" do
          old_value = consultant.google_analytics_code

          get "/bureau_consultant/home"

          assert_equal old_value, consultant.reload.google_analytics_code
        end

        it "renders the existing google_analytics_id in the page" do
          get "/bureau_consultant/home"

          assert response.body.match(/'userId' : '#{consultant.reload.google_analytics_code}'/)
        end
      end
    end
  end

  describe "not authenticated" do
    describe "on a mobile" do
      it "redirects to the authentication page" do
        get "/m/bureau_consultant/home"
        assert_redirected_to "/cas_authentications/sign_in"
      end
    end

    it "redirects to the authentication page" do
      get "/bureau_consultant/home"
      assert_redirected_to "/cas_authentications/sign_in"
    end
  end
end
require "test_helper"

describe BureauConsultant::HomeController do
  describe "authenticated as a consultant" do
    let(:consultant) { Goxygene::Consultant.find 9392 }

    before do
      sign_in cas_authentications(:jackie_denesik)
    end

    describe "on a mobile" do
      it "displays the home page" do
        get "/m/bureau_consultant/home"
        assert_response :success
      end
    end

    it "displays the home page" do
      get "/bureau_consultant/home"
      assert_response :success
    end

    it "fetches the last 3 articles"

    it "fetches the rss feed" do
      get "/bureau_consultant/home"
      assert_select "div.actus-feeds a div.actus-boxes"
    end

    describe "for the google_analytics_id" do
      describe "when the consultant does not have one" do
        before do
          consultant.update! google_analytics_code: nil
          sign_in CasAuthentication.find_by(cas_user_id: consultant.id)
        end

        it "creates the google_analytics_id in database" do
          get "/bureau_consultant/home"

          assert_not_nil consultant.reload.google_analytics_code
        end

        it "renders the newly created google_analytics_id in the page" do
          get "/bureau_consultant/home"

          assert response.body.match(/'userId' : '#{consultant.reload.google_analytics_code}'/)
        end
      end

      describe "when the consultant already have one" do
        it "does not change the entry in database" do
          old_value = consultant.google_analytics_code

          get "/bureau_consultant/home"

          assert_equal old_value, consultant.reload.google_analytics_code
        end

        it "renders the existing google_analytics_id in the page" do
          get "/bureau_consultant/home"

          assert response.body.match(/'userId' : '#{consultant.reload.google_analytics_code}'/)
        end
      end
    end
  end

  describe "not authenticated" do
    describe "on a mobile" do
      it "redirects to the authentication page" do
        get "/m/bureau_consultant/home"
        assert_redirected_to "/cas_authentications/sign_in"
      end
    end

    it "redirects to the authentication page" do
      get "/bureau_consultant/home"
      assert_redirected_to "/cas_authentications/sign_in"
    end
  end
end

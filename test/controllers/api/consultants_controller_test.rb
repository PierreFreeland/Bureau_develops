# frozen_string_literal: true

require "test_helper"

describe Api::ConsultantsController do
  let(:authorization_header) do
    client = Doorkeeper::Application.create(
      user_id: Goxygene::Employee.first.id,
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
      scopes: "public write",
      name: "test"
    )
    scopes = Doorkeeper::OAuth::Scopes.from_string("public")
    creator = Doorkeeper::OAuth::ClientCredentials::Creator.new
    token = creator.call(client, scopes)

    { "Authorization": "Bearer #{token.token}" }
  end

  describe "Get consultants list" do
    describe "Not authenticated using a token" do
      it "should reject with not authorized" do
        get "/api/consultants"
        assert_response :unauthorized
      end
    end

    describe "Authenticated using a token" do
      it "should respond with a JSON" do
        get "/api/consultants", headers: authorization_header

        assert_response :ok

        json = JSON.parse(response.body)
        expected_count = Goxygene::Consultant.where(consultant_status: "consultant").joins(:contact_datum, :individual).count
        actual_count = json.size
        assert_equal expected_count, actual_count
      end
    end
  end

  describe "Get consultant info by email" do
    let(:valid_email) { "Liane%2eBahringer_13894@consulting-itg%2efr" }
    let(:invalid_email) { "idontexist@anywhere.com" }

    describe "Not authenticated using a token" do
      it "should reject with not authorized" do
        get "/api/consultants/email/#{valid_email}"
        assert_response :unauthorized
      end
    end

    describe "Authenticated using a token" do
      it "should respond with NOT FOUND if email isn't a consultant valid one" do
        assert_raises(ActiveRecord::RecordNotFound) do
          get "/api/consultants/email/#{invalid_email}", headers: authorization_header
        end
      end

      it "should return consultant JSON if email is valid" do
        get "/api/consultants/email/#{valid_email}", headers: authorization_header
        assert_response :ok

        json = JSON.parse(response.body)
        assert_equal CGI.unescape(valid_email), json["email"]
      end
    end
  end
end

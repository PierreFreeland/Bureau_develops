# frozen_string_literal: true

require "test_helper"

describe Api::SpecialitiesController do
  describe "Not authenticated using a token" do
    it "should reject with not authorized" do
      get "/api/specialities"
      assert_response :unauthorized
    end
  end

  describe "Authenticated using a token" do
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

    it "should retrieved an ordered specialities list" do
      get "/api/specialities", headers: authorization_header

      assert_response :ok

      json = JSON.parse(response.body)
      assert json.key?("specialities")
      assert_equal Goxygene::ConsultantActivity.active.count, json["specialities"].size
      assert_equal "Autre", json["specialities"].last["description"]
    end
  end
end

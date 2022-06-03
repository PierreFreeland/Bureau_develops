require "test_helper"

module Api
  module V2
    describe ConsultantsController do
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
        describe "Authenticated using a token" do
          it "should respond with a JSON" do
            get "/api/v2/consultants", headers: authorization_header

            assert_response :ok

            json = JSON.parse(response.body)
            expected_count = Consultant.active_consultant.count
            actual_count = json.size
            assert_equal expected_count, actual_count
          end
        end
      end

      describe "Search consultants" do
        describe "Authenticated using a token" do
          it "should respond with JSON of matched consultant by given email" do
            sample_email = 'test_search_consultant_with_email@demo.com'
            consultant = Consultant.active_consultant.first
            consultant.contact_datum.update(email: sample_email)
            get "/api/v2/consultants/email/#{sample_email}", headers: authorization_header
            assert_response :ok

            json = JSON.parse(response.body)
            assert_equal consultant.id, json["id"]
          end
        end
      end
    end

  end
end

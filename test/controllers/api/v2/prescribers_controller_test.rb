require "test_helper"

module Api
  module V2
    describe PrescribersController do
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

      describe "Get prescriber list" do
        describe "Authenticated using a token" do
          it "should respond with a JSON" do
            active = 1
            get "/api/v2/prescribers",
                headers: authorization_header,
                params: {
                    active: active
                }

            assert_response :ok

            json = JSON.parse(response.body)
            expected_count = Prescriber.by_active(active).size
            actual_count = json.size
            assert_equal expected_count, actual_count
          end
        end
      end

      describe "Get a prescriber" do
        describe "Authenticated using a token" do
          it "should respond with a JSON" do
            prescriber = Prescriber.first
            active = prescriber.active
            get "/api/v2/prescribers/#{prescriber.id}",
                headers: authorization_header,
                params: {
                    active: active
                }
            assert_response :ok

            json = JSON.parse(response.body)
            assert_equal prescriber.id, json["id"]
          end
        end
      end
    end

  end
end

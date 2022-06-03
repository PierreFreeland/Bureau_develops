require "test_helper"

module Api
  module V2
    describe TimelineReferentialForProspectsController do
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

      describe "Get timeline referential for prospects data" do
        describe "Authenticated using a token" do
          it "should respond with a JSON" do
            get "/api/v2/timeline_referential_for_prospects",
                headers: authorization_header

            assert_response :ok

            json = JSON.parse(response.body)

            expected_data = {
                "communication_motives" =>  CommunicationMotive.all,
                "timeline_status_enum" =>  TimelineItem.status.options.to_hash_options,
                "timeline_types" => TimelineType.all,
            }

            assert_equal expected_data.size, json.size

            expected_data.each do |key, value|
              assert_equal value.size, json[key]&.size, "Not equal at #{key}"
            end
          end
        end
      end
    end
  end
end

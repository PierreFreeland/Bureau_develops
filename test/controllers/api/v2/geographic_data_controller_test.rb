require "test_helper"

module Api
  module V2
    describe Api::V2::GeographicDataController do
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

      describe "Get geographic data list" do
        describe "Authenticated using a token" do
          it "should respond with a JSON" do
            get "/api/v2/geographic_data", headers: authorization_header

            assert_response :ok

            json = JSON.parse(response.body)

            expected_data = {
                "continents" => Continent.all,
                "sub_continents" => Subcontinent.all,
                "countries" => Country.all,
                "regions" => Region.all,
                "departments" => Department.all,
                "cities" => City.all,
                "zip_codes" => ZipCode.all,
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

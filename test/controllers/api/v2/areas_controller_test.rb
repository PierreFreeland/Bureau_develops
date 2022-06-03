require "test_helper"

module Api
  module V2
    describe AreasController do
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

      describe "Get area list" do
        describe "Authenticated using a token" do
          it "should respond with a JSON" do
            employee = Employee.first
            active = 1
            get "/api/v2/areas",
                headers: authorization_header,
                params: {
                    active: active,
                    employee_id: employee.id
                }

            assert_response :ok

            json = JSON.parse(response.body)
            expected_count = Area.by_active(active).by_employee_id(employee.id).size
            actual_count = json.size
            assert_equal expected_count, actual_count
          end
        end
      end

      describe "Get an area" do
        describe "Authenticated using a token" do
          it "should respond with a JSON" do
            area = Area.first
            get "/api/v2/areas/#{area.id}", headers: authorization_header
            assert_response :ok

            json = JSON.parse(response.body)
            assert_equal area.id, json["id"]
          end
        end
      end
    end

  end
end

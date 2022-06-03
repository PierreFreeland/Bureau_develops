require "test_helper"
module Api
  module V2
    describe EmployeesController do
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

      describe "Get employee role list" do
        describe "Authenticated using a token" do
          it "should respond with a JSON" do
            roles = EmployeeRole.first(2).pluck(:id)
            active = 1
            get "/api/v2/employees",
                headers: authorization_header,
                params: {
                    roles: roles,
                    active: active
                }

            assert_response :ok

            json = JSON.parse(response.body)
            expected_count = Employee.by_active(active).by_roles(roles).size
            actual_count = json.size
            assert_equal expected_count, actual_count
          end
        end
      end
    end
  end
end

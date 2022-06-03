require "test_helper"

module Api
  module V2
    describe Client::ArticlesController do

      URL = "/api/v2/client/articles"

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

      describe "Get articles list" do
        describe "Authenticated using a token" do
          it "should respond with a JSON" do
            get URL,
                headers: authorization_header,
                params: {
                }

            assert_response :ok

            json = JSON.parse(response.body)
            expected_count = Goxygene::Article.by_bureau(:client).only_active.size
            actual_count = json.size
            assert_equal expected_count, actual_count
          end
        end
      end
    end

  end
end

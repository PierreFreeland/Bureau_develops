require "test_helper"

module Api
  module V2
    describe Api::V2::Consultants::AlertsController do
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

      let(:consultant) { Consultant.first }
      let(:comment) { 'Demo alert' }

      it "should error out because of missing param contact_reason_id" do
        post "/api/v2/consultants/#{consultant.id}/alert",
             headers: authorization_header,
             params: {}
        assert_response :bad_request
      end

      it "should create consultant's alert timeline item without comment" do
        assert_difference "Goxygene::TimelineItem.count" do
          post "/api/v2/consultants/#{consultant.id}/alert",
               headers: authorization_header,
               params: { contact_reason_id: 1 }
        end

        assert_response :ok

        json = JSON.parse(response.body)
        assert json["id"].present?
      end

      it "should create consultant's alert timeline item with comment" do
        assert_difference "Goxygene::TimelineItem.count" do
          post "/api/v2/consultants/#{consultant.id}/alert",
               headers: authorization_header,
               params: { contact_reason_id: 1, comment: comment }
        end

        assert_response :ok

        json = JSON.parse(response.body)
        assert json["id"].present?
        assert_equal comment, json["comment"]
      end
    end
  end
end

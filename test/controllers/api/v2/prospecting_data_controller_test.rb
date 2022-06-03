require "test_helper"
require "open-uri"

module Api
  module V2
    describe Api::V2::ProspectingDataController do
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

      let(:prospect) { Goxygene::ProspectingDatum.find(5030) }
      let(:consultant_activity) { Goxygene::ConsultantActivity.first }

      describe "Get prospects from given data" do
        describe "Authenticated using a token" do
          describe "With prospect id in URL" do
            it "should respond with a JSON" do
              get "/api/v2/prospects/#{prospect.id}", headers: authorization_header

              assert_response :ok

              json = JSON.parse(response.body)
              assert_equal prospect.id, json['id']
            end
          end

          describe "With prospect email in URL" do
            it "should respond with a JSON" do
              prospect_email = prospect.consultant.contact_datum.email
              get "/api/v2/prospects/#{prospect_email}", headers: authorization_header

              assert_response :ok

              json = JSON.parse(response.body)
              assert_equal prospect.id, json['id']
            end
          end

          describe "Search with prospect phone number in URL" do
            it "should respond with JSON array of prospects" do
              prospect_phone = "00339999999"
              prospect.consultant.contact_datum.update(phone: prospect_phone)
              get "/api/v2/prospects/phone/#{prospect_phone}", headers: authorization_header

              assert_response :ok

              json = JSON.parse(response.body)
              assert_equal prospect.id, json[0]['id']
            end
          end
        end
      end

      describe "Create prospect" do
        describe "Authenticated using a token" do
          describe "With all required params" do
            it "should respond with a JSON" do
              post "/api/v2/prospects",
                   headers: authorization_header,
                   params: {
                       civility_id: 1,
                       firstname: "Firstname",
                       lastname: "Lastname",
                       email: "firstname.lastname@demo.com",
                       zipcode: Goxygene::ZipCode.first.zip_code,
                       phone: "0299807299",
                       speciality_id: consultant_activity.id,
                       form_type: "Rappel",
                       referring_website: "https://www.demo.com",
                       arrival_url: "https://www.demo.com"
                   }

              assert_response :created

              json = JSON.parse(response.body)
              assert json["id"].present?
            end
          end
        end
      end

      describe "Update prospect" do
        describe "Authenticated using a token" do
          describe "With prospect's id and updating params" do
            it "should respond with a JSON" do
              put "/api/v2/prospects/#{prospect.id}",
                   headers: authorization_header,
                   params: {
                       individual: {
                           first_name: "Newname",
                       }
                   }

              assert_response :ok

              json = JSON.parse(response.body)
              assert_equal prospect.id, json['id']
            end
          end
        end
      end

    end
  end
end

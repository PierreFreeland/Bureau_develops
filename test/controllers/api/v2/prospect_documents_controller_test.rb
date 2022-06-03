require "test_helper"
require "open-uri"

module Api
  module V2
    describe Api::V2::ProspectDocumentsController do
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

      let(:document) { Goxygene::Document.find(370670) }
      let(:consultant) { document.tier.individual.consultant }

      describe "Get prospect's documents list from given consultant_id" do
        describe "Authenticated using a token" do
          it "should respond with a JSON" do
            get "/api/v2/prospect_documents",
                headers: authorization_header,
                params: {
                    consultant_id: consultant.id
                }

            assert_response :ok

            json = JSON.parse(response.body)
            expected_count = Goxygene::Document.where(tier: consultant.individual.tier).count
            actual_count = json.size
            assert_equal expected_count, actual_count
          end
        end
      end

      describe "Create prospect's document" do
        describe "Authenticated using a token" do
          describe "With upload file selected" do
            it "should respond with a JSON" do
              post "/api/v2/prospect_documents",
                   headers: authorization_header,
                   params: {
                       document_type_id: 251,
                       document_format_id: 11,
                       file: fixture_file_upload('files/sample_document.pdf', 'application/pdf'),
                       consultant_id: consultant.id
                   }

              assert_response :ok

              json = JSON.parse(response.body)
              assert json["id"].present?
            end
          end
          describe "No upload file selected" do
            it "should get an error message" do
              post "/api/v2/prospect_documents",
                   headers: authorization_header,
                   params: {
                       consultant_id: consultant.id,
                   }

              assert_response :bad_request

              json = JSON.parse(response.body)
              assert_equal 'require params file', json['message']
            end
          end
        end
      end

      describe "Update prospect's document" do
        describe "Authenticated using a token" do
          describe "Without document id to be update" do
            it "should respond with error" do
              post "/api/v2/prospect_documents",
                   headers: authorization_header,
                   params: {
                       valid_from: Date.current.to_s(:db)
                   }

              assert_response :bad_request
            end
          end
          describe "With new file to replace the existing one" do
            it "should respond with a JSON" do
              post "/api/v2/prospect_documents",
                   headers: authorization_header,
                   params: {
                       id: document.id,
                       file: fixture_file_upload('files/sample1.pdf', 'application/pdf'),
                   }

              assert_response :ok

              json = JSON.parse(response.body)
              assert_equal document.id, json["id"]
            end
          end
          describe "With document's id and data to be changed" do
            it "should respond with a JSON" do
              new_valid_from = Date.current.to_s(:db)
              post "/api/v2/prospect_documents",
                   headers: authorization_header,
                   params: {
                       id: document.id,
                       valid_until: new_valid_from
                   }

              assert_response :ok

              json = JSON.parse(response.body)
              assert_equal document.id, json["id"]
              assert_equal new_valid_from, json["valid_until"]
            end
          end
        end
      end

      describe "Delete prospect's document" do
        describe "Authenticated using a token" do
          it "should respond with no error" do
            assert_difference 'Goxygene::Document.count', -1 do
              delete "/api/v2/prospect_documents/#{document.id}", headers: authorization_header
            end
          end
        end
      end

    end
  end
end

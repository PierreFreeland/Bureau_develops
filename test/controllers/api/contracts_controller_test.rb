# frozen_string_literal: true

require "test_helper"

describe Api::ContractsController do
  describe "Contract signature callback" do
    let(:params) do
      {
        "signature_id": 56_300,
        "external_id": "contract_tracking_34227",
        "status": "archived",
        "document_download_url": "https://itg.staging.eu.people-doc.com/api/v1/signatures/56300/download/",
        "errors": []
      }
    end

    it "should update the contract" do
      # We don't want to reach the document server in tests
      OpenURI.stub(:open_uri, fixture_file_upload(Rails.root.join("test", "fixtures", "files", "sample1.pdf"))) do
        assert_difference "Goxygene::EmploymentContractDocument.count" do
          post "/api/contracts/34227/callback", params: params
        end
      end

      assert_response :ok
    end
  end
end

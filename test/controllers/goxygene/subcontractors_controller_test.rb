require 'test_helper'

describe Goxygene::SubcontractorsController do
  before do
    @subcontractor_data =  {
      "subcontractor"=>{
        "correspondant_employee_id"=>"304",
        "itg_margin"=>"12",
        "individual_attributes"=>{
          "last_name"=>"Regif",
          "first_name"=>"Paul-Jean",
          "civility_id"=>"1",
        },
        "contact_datum_attributes"=>{
          "country_id"=>"58",
          "zip_code"=>"75016",
          "zip_code_id"=>"32472",
          "city"=>"PARIS",
          "address_1"=>"La Bas, ailleurs...",
          "address_2"=>"pas ici, La Bas",
          "mobile_phone"=>"+33102030406",
          "email"=>"regif.pj@rimalis.me.com"
        },
        "establishment_id"=>"63165",
        "establishment_attributes"=>{
          "bank_account_attributes"=>{
            "account_holder"=>"john doe",
            "banking_domiciliation"=>"paris",
            "iban"=>"FR7630001007941234567890185",
            "swift"=>"ABNAFRPP",
            "document_attributes"=>{
              "filename"=>fixture_file_upload('files/sample1.pdf', 'application/pdf'),
              "document_type_id"=>"5043",
              "document_format_id"=>Goxygene::DocumentFormat.find_by(file_extension: 'PDF').id,
            }
          }
        }
      }
    }
  end

  describe 'authenticated as an administrator' do
    before do
      sign_in cas_authentications(:administrator)
    end

    it 'displays the subcontractors list page' do
      get '/goxygene/subcontractors'
      assert_response :success
    end

    it 'create a new subcontractor in database' do
      Goxygene::SubcontractorWelcomeMailProcessor = Minitest::Mock.new
      Goxygene::SubcontractorWelcomeMailProcessor.expect(:run, true, [Goxygene::Subcontractor])
      assert_difference 'Goxygene::Subcontractor.count', 1 do
        post '/goxygene/subcontractors', params: @subcontractor_data
      end
    end
  end

  describe 'not authenticated' do
    describe 'when submitting a new prospect request' do
      it 'does not create a new prospect in database' do
        assert_no_difference 'Goxygene::Individual.count' do
          post '/goxygene/subcontractors', params: @subcontractor_data
        end
      end
      it 'redirects to the authentication page' do
        get '/goxygene/subcontractors'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end
  end
end

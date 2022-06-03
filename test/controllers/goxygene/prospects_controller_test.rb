require 'test_helper'

describe 'Goxygene::ProspectsController' do
    before do
        @prospect_data =  {"prospecting_datum"=>{"consultant_attributes"=>{"individual_attributes"=>{"last_name"=>"Regif", "first_name"=>"Paul-Jean"}, "consultant_activity_id"=>"1", "contact_datum_attributes"=>{"country_id"=>"58", "zip_code"=>"75016", "city"=>"PARIS", "address_1"=>"La Bas, ailleurs...", "phone"=>"0102030406", "email"=>"regif.pj@rimalis.me.com"}, "comment"=>"Bah ?!"}}, "zip_code_temp"=>"32472"}
    end
    
#   describe 'authenticated as an administrator' do
#     before do
#       sign_in cas_authentications(:administrator)
#     end

#     it 'displays the home page' do
#       get '/goxygene/prospects'
#       assert_response :success
#     end
#   end

  describe 'not authenticated' do
    describe 'when submitting a new prospect request' do
        it 'does not create a new prospect in database' do
          assert_no_difference 'Goxygene::Individual.count' do
            post '/goxygene/prospects', params: @prospect_data
          end
        end
    it 'redirects to the authentication page' do
      get '/goxygene/dashboard'
      assert_redirected_to '/cas_authentications/sign_in'
     end
     end
    end
end
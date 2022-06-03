require 'test_helper'

describe 'BureauConsultant::BillingPointsController' do
  describe 'authenticated as a consultant' do

    let(:consultant)    { Goxygene::Consultant.find 9392  }
    let(:billing_point) { consultant.establishments_from_contacts.first }

    before { sign_in cas_authentications(:jackie_denesik) }

    describe 'on the index action' do
      it 'returns a list of billing points' do
        get '/bureau_consultant/billing_points'

        assert_response :success
      end
    end

    describe 'on the show action' do
      before { get "/bureau_consultant/billing_points/#{billing_point.id}" }

      let(:parsed) { JSON.parse response.body }

      it 'returns details related to a specific billing point' do
        assert_response :success
      end

      it 'returns the correct country id' do
        assert_not_nil billing_point.contact_datum.country_id

        assert_equal billing_point.contact_datum.country_id, parsed['country_id']
      end

      it 'returns the zipcode' do
        assert_not_nil   billing_point.contact_datum.zip_code
        assert_not_empty billing_point.contact_datum.zip_code

        assert_equal billing_point.contact_datum.zip_code, parsed['zip_code']
      end

      it 'returns the city' do
        assert_not_nil   billing_point.contact_datum.city
        assert_not_empty billing_point.contact_datum.city

        assert_equal billing_point.contact_datum.city, parsed['city']
      end

      describe 'establishment contacts' do
        it 'is not empty' do
          assert_not_empty billing_point.establishment_contacts

          assert_not_nil   parsed['establishment_contacts']
          assert_not_empty parsed['establishment_contacts']
        end

        it 'scopes results for current consultant' do
          parsed['establishment_contacts'].each do |contact|
            contact_from_db = Goxygene::EstablishmentContact.find contact['id']
            assert_equal consultant.id, contact_from_db.consultant_id
          end
        end

        %i{ id last_name first_name
            contact_type_id contact_role_id
            country_id zip_code zip_code_id city
            address_1 address_2 address_3
            phone email
          }.each do |attr|
          it "returns a #{attr} attribute" do
            assert_not_nil   parsed['establishment_contacts'].first[attr.to_s]
            assert_not_empty parsed['establishment_contacts'].first[attr.to_s].to_s
          end
        end

      end
    end
  end
end

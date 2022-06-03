require 'test_helper'

describe 'BureauConsultant::CommercialContractsController' do
  describe 'authenticated as a consultant' do

    CommercialContractRequestsIds = %w{
      40004 35708 40018 40015 40005 39464 39457 39780 40090 32143 31304 31298 31306 31297 31309
      31295 33310 39623 31312 31300 31305 31308 31301 31255 31307 30931 31313 32928 33311 33312
      35660 39466 35709
    }

    CommercialContractRequestsIds = CommercialContractRequestsIds.shuffle[0..5] unless ENV['ALL']

    let(:consultant)               { Goxygene::Consultant.find 9392          }
    let(:establishment)            { consultant.establishments_from_contacts.first         }
    let(:mission_subject)          { FFaker::Lorem.words(5).join(' ')        }
    let(:beginning_date)           { Date.current + 2.days                   }
    let(:ending_date)              { beginning_date + 5.days                 }
    let(:order_amount)             { rand(5000) + 200                        }
    let(:daily_order_amount)       { rand(5000) + 250                        }
    let(:establishment_name)       { FFaker::Name.name                       }
    let(:first_name)               { FFaker::Name.first_name                 }
    let(:last_name)                { FFaker::Name.last_name.upcase           }
    let(:consultant_comment)       { FFaker::Lorem.words(5).join(' ')        }
    let(:expenses_comment)         { FFaker::Lorem.words(5).join(' ')        }
    let(:expenses_payback_comment) { FFaker::Lorem.words(5).join(' ')        }
    let(:contract_handling_comment){ FFaker::Lorem.words(5).join(' ')        }
    let(:notice_period)            { rand(5)                                 }
    let(:vat_id)                   { 12                                      }
    let(:vat)                      { Goxygene::Vat.find(vat_id)              }
    let(:time_length)              { 2                                       }
    let(:contact_type)             { Goxygene::ContactType.all.shuffle.first }
    let(:contact_role)             { Goxygene::ContactRole.all.shuffle.first }

    let(:new_siret)                { '73282932000074'               }
    let(:siret_with_spaces)        { "\t8304 085 630 0013"          }
    let(:new_name)                 { FFaker::Name.name              }
    let(:new_address)              { FFaker::Address.street_address }
    let(:new_zip_code)             { "12345"                        }
    let(:new_city)                 { FFaker::Address.city           }

    let(:country_not_france)       { Goxygene::Country.find 22 }

    let(:establishment_contact)    { establishment.establishment_contacts.first }

    let(:contract_attributes) do
      {
        establishment_vat_number: '',
        establishment_siret:      new_siret,
        establishment_name:       establishment_name,
        establishment_country_id: establishment.contact_datum.country_id,
        establishment_address_1:  establishment.address_1,
        establishment_address_2:  establishment.address_2,
        establishment_address_3:  establishment.address_3,
        establishment_zip_code:   establishment.contact_datum.zip_code,
        establishment_city:       establishment.contact_datum.city,
        establishment_phone:      establishment.contact_datum.phone,

        contact_last_name:        last_name,
        contact_first_name:       first_name,
        contact_contact_type_id:  contact_type.id,
        contact_contact_role_id:  contact_role.id,
        contact_country_id:       establishment.contact_datum.country_id,
        contact_address_1:        establishment.address_1,
        contact_address_2:        establishment.address_2,
        contact_address_3:        establishment.address_3,
        contact_zip_code:         establishment.contact_datum.zip_code,
        contact_city:             establishment.contact_datum.city,
        contact_phone:            establishment.contact_datum.phone,
        contact_email:            establishment.contact_datum.email,

        mission_subject:    mission_subject,
        begining_date:      beginning_date,
        ending_date:        ending_date,
        time_length:        time_length,
        daily_order_amount: daily_order_amount,
        order_amount:       order_amount,
        vat_id:             vat_id,
        advance_payment:    "",
        notice_period:      notice_period,

        consultant_comment:         consultant_comment,
        expenses_comment:           expenses_comment,
        expenses_payback_comment:   expenses_payback_comment,
        contract_handling_comment:  contract_handling_comment,

        consultant_itg_establishment_id: consultant.itg_establishment_id
      }
    end

    let(:current_contract) do
      contract = consultant.office_business_contracts.build
      contract.assign_attributes contract_attributes
      contract.created_by = cas_authentications(:jackie_denesik).cas_user.id
      contract.updated_by = cas_authentications(:jackie_denesik).cas_user.id
      contract.office_customer_update.created_by = cas_authentications(:jackie_denesik).cas_user.id
      contract.office_customer_update.updated_by = cas_authentications(:jackie_denesik).cas_user.id
      contract.office_customer_update.contact_datum.created_by = cas_authentications(:jackie_denesik).cas_user.id
      contract.office_customer_update.contact_datum.updated_by = cas_authentications(:jackie_denesik).cas_user.id
      contract.save!
      contract
    end

    let(:document) do
      consultant.individual.tier.documents.create!(
        filename:        fixture_file_upload('files/sample1.pdf', 'application/pdf'),
        document_type:   Goxygene::DocumentType.commercial_contract_annex,
        document_format: Goxygene::DocumentFormat.find_by(file_extension: 'PDF'),
        created_by:      cas_authentications(:jackie_denesik).cas_user.id,
        updated_by:      cas_authentications(:jackie_denesik).cas_user.id,
      )
    end

    let(:current_contract_with_attachment) do
      current_contract.office_business_contracts_documents.create!(
        document:   document,
        created_by: cas_authentications(:jackie_denesik).cas_user.id,
        updated_by: cas_authentications(:jackie_denesik).cas_user.id,
      )
      current_contract
    end

    before { sign_in cas_authentications(:jackie_denesik) }

    describe 'on mobile' do
      describe 'on the contract request history page' do

        it 'displays the contract requests history page' do
          get '/m/bureau_consultant/commercial_contracts/contract_request'
          assert_response :success
        end
      end

      describe 'on the contract signed history page' do

        it 'displays the contracts signed history page' do
          get '/m/bureau_consultant/commercial_contracts/contract_signed'
          assert_response :success
        end

      end

    end

    describe 'on the contract_request_show action' do
      CommercialContractRequestsIds.each do |contract_id|
        it "renders the bill #{contract_id}" do
          consultant = Goxygene::OfficeBusinessContract.find(contract_id).consultant

          sign_in CasAuthentication.find_by(cas_user_type: 'Goxygene::Consultant', cas_user_id: consultant)

          get "/bureau_consultant/commercial_contracts/contract_request/#{contract_id}.pdf"

          assert_response :success
        end
      end
    end

    describe 'on the index (billing_points/commercial_contracts) action' do
      describe 'for the given billint point' do
        let(:parsed_response) { JSON.parse response.body }

        before { get "/bureau_consultant/billing_points/#{establishment.id}/commercial_contracts" }

        it 'lists the contracts' do
          parsed = JSON.parse response.body
        end

        it 'responds with success' do
          assert_response :success
        end

        it 'returns the contract id' do
          parsed_response.each do |entry|
            assert_not_nil entry['id']
          end
        end

        it 'returns the contract begining_date' do
          parsed_response.each do |entry|
            database_entry = Goxygene::BusinessContract.find entry['id']
            assert_equal database_entry.begining_date.strftime("%d/%m/%Y"), entry['begin_date']
          end
        end

        it 'returns the contract ending_date' do
          parsed_response.each do |entry|
            database_entry = Goxygene::BusinessContract.find entry['id']
            assert_equal database_entry.ending_date.strftime("%d/%m/%Y"), entry['end_date']
          end

        end
      end
    end

    describe 'on the load_default_vat_rate' do
      before { current_contract }

      it 'returns the default vat_rate for given country' do
        get '/bureau_consultant/commercial_contracts/load_default_vat_rate', params: { country_code: 1 }

        assert_equal Goxygene::Country.find(1).default_vat.id.to_s, response.body
      end

      it 'does not raise an error when country_code is empty' do
        get '/bureau_consultant/commercial_contracts/load_default_vat_rate', params: { country_code: nil }

        assert_response :not_found
      end

      it 'does not raise an error when no country code is given' do
        get '/bureau_consultant/commercial_contracts/load_default_vat_rate'

        assert_response :not_found
      end

    end

    describe 'on the destroy pending action' do
      before { current_contract }

      def get_destroy_pending(attrs = {})
        get "/bureau_consultant/commercial_contracts/contract_request/pending/destroy"
      end

      it 'deletes the entry from database' do
        assert_difference 'Goxygene::OfficeBusinessContract.count', -1 do
          get_destroy_pending
        end
      end

      it 'redirects to the new contract page' do
        get_destroy_pending

        assert_redirected_to '/bureau_consultant/commercial_contracts/new'
      end
    end

    describe 'on the validates action' do
      before { current_contract }

      def post_validates(attrs = {})
        post "/bureau_consultant/commercial_contracts/#{current_contract.id}/validate"
      end

      it 'does not create a new entry' do
        assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
          post_validates
        end
      end

      it 'validates the contract' do
        post_validates

        assert_equal 'office_validated', current_contract.reload.business_contract_status
      end

      it 'sets the consultant_validation timestamp' do
        post_validates

        assert ((Time.now.to_i - 10)..(Time.now.to_i + 10)).include? current_contract.reload.consultant_validation.to_i
      end

      it 'redirects to contract_request_commercial_contracts_path' do
        post_validates

        assert_redirected_to '/bureau_consultant/commercial_contracts/contract_request'
      end

      it 'does not reset the time_length' do
        time_length = 5 + rand(123)

        current_contract.update! billing_mode: 'fixed_price',
                                 time_length: time_length

        post_validates

        assert_equal time_length, current_contract.reload.time_length
      end
    end

    describe 'on the create action' do
      def post_create(attrs: {}, attachments: [])
        post '/bureau_consultant/commercial_contracts', params: {
          office_business_contract: contract_attributes.merge(attrs),
          attachments: attachments
        }
      end

      describe 'when the establishment name is empty' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: { establishment_name: nil }
          end
        end

        it 'render the error' do
          post_create attrs: { establishment_name: nil }

          assert_select "form#new_office_business_contract"
        end

        it 'does not duplicate the error message' do
          post_create attrs: { establishment_name: nil }

          error_messages = css_select('div#error_explanation ul li').collect(&:text)

          assert_equal error_messages.uniq.count, error_messages.count
        end
      end

      describe 'when the establishment city is empty' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: { establishment_city: nil }
          end
        end

        it 'render the error' do
          post_create attrs: { establishment_city: nil }

          assert_select "form#new_office_business_contract"
        end

        it 'does not duplicate the error message' do
          post_create attrs: { establishment_city: nil }

          error_messages = css_select('div#error_explanation ul li').collect(&:text)

          assert_equal error_messages.uniq.count, error_messages.count
        end
      end

      describe 'when the establishment zip_code is empty' do
        describe 'when the country is France' do
          it 'does not create anything in database' do
            assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
              post_create attrs: { establishment_zip_code: nil }
            end
          end

          it 'render the error' do
            post_create attrs: { establishment_zip_code: nil }

            assert_select "form#new_office_business_contract"
          end

          it 'does not duplicate the error message' do
            post_create attrs: { establishment_zip_code: nil }

            error_messages = css_select('div#error_explanation ul li').collect(&:text)

            assert_equal error_messages.uniq.count, error_messages.count
          end
        end

        describe 'when the country is France' do
          it 'creates the entry in database' do
            assert_difference 'Goxygene::OfficeBusinessContract.count' do
              post_create attrs: { establishment_id: nil, establishment_zip_code: nil, establishment_country_id: country_not_france.id }
            end
          end

          it 'sets the right values' do
            post_create attrs: { establishment_id: nil, establishment_zip_code: nil, establishment_country_id: country_not_france.id }

            office_business_contract = consultant.office_business_contracts.last

            assert_equal '',                                      office_business_contract.establishment_vat_number.to_s.strip
            assert_equal new_siret,                                      office_business_contract.establishment_siret.to_s.strip

            assert_equal establishment_name,                      office_business_contract.establishment_name
            assert_equal establishment.contact_datum.address_2,   office_business_contract.establishment_address_2
            assert_nil                                            office_business_contract.establishment_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.establishment_city
            assert_equal country_not_france.id,                   office_business_contract.establishment_country_id
            assert_equal establishment.contact_datum.phone,       office_business_contract.establishment_phone

            assert_equal last_name,                               office_business_contract.contact_last_name
            assert_equal first_name,                              office_business_contract.contact_first_name
            assert_equal contact_type.id,                         office_business_contract.contact_contact_type.id
            assert_equal contact_role.id,                         office_business_contract.contact_contact_role.id
            assert_equal establishment.contact_datum.country_id,  office_business_contract.contact_country_id
            assert_equal establishment.contact_datum.zip_code,    office_business_contract.contact_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.contact_city
            assert_equal establishment.contact_datum.phone,       office_business_contract.contact_phone
            assert_equal establishment.contact_datum.email,       office_business_contract.contact_email

            assert_equal mission_subject,                         office_business_contract.mission_subject
            assert_equal beginning_date,                          office_business_contract.begining_date
            assert_equal ending_date,                             office_business_contract.ending_date
            assert_equal time_length,                             office_business_contract.time_length
            assert_equal order_amount,                            office_business_contract.order_amount
            assert_equal daily_order_amount,                      office_business_contract.daily_order_amount
            assert_equal consultant_comment,                      office_business_contract.consultant_comment
            assert_equal expenses_comment,                        office_business_contract.expenses_comment
            assert_equal expenses_payback_comment,                office_business_contract.expenses_payback_comment
            assert_equal contract_handling_comment,               office_business_contract.contract_handling_comment
            assert_equal notice_period,                           office_business_contract.notice_period
          end

          it 'responds with success' do
            post_create attrs: { establishment_id: nil, establishment_zip_code: nil, establishment_country_id: country_not_france.id }

            assert_response :success
          end

          it 'renders the preview form' do
            post_create attrs: { establishment_id: nil, establishment_zip_code: nil, establishment_country_id: country_not_france.id }

            assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
          end

          it 'includes the client name in the preview form' do
            post_create attrs: { establishment_id: nil, establishment_zip_code: nil, establishment_country_id: country_not_france.id }

            assert_select "div.establishment_name", establishment_name
          end

          it 'includes the contract VAT rate in the preview form' do
            post_create attrs: { establishment_id: nil, establishment_zip_code: nil, establishment_country_id: country_not_france.id }

            assert_select "div.vat_rate", "#{vat.label} - #{vat.rate}%"
          end
        end

      end

      describe 'when the mission subject is empty' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: { mission_subject: nil }
          end
        end

        it 'render the error' do
          post_create attrs: { mission_subject: nil }

          assert_select "form#new_office_business_contract"
        end

        it 'does not duplicate the error message' do
          post_create attrs: { mission_subject: nil }

          error_messages = css_select('div#error_explanation ul li').collect(&:text)

          assert_equal error_messages.uniq.count, error_messages.count
        end
      end

      describe 'when the begining_date is empty' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: { begining_date: nil }
          end
        end

        it 'render the error' do
          post_create attrs: { begining_date: nil }

          assert_select "form#new_office_business_contract"
        end

        it 'does not duplicate the error message' do
          post_create attrs: { begining_date: nil }

          error_messages = css_select('div#error_explanation ul li').collect(&:text)

          assert_equal error_messages.uniq.count, error_messages.count
        end
      end

      describe 'when the begining_date is more than 3 months in the past' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: { begining_date: 4.months.ago.to_date }
          end
        end

        it 'render the error' do
          post_create attrs: { begining_date: 4.months.ago.to_date }

          assert_select "form#new_office_business_contract"
        end

        it 'does not duplicate the error message' do
          post_create attrs: { begining_date: 4.months.ago.to_date }

          error_messages = css_select('div#error_explanation ul li').collect(&:text)

          assert_equal error_messages.uniq.count, error_messages.count
        end
      end

      describe 'when the ending_date is empty' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: { ending_date: nil }
          end
        end

        it 'render the error' do
          post_create attrs: { ending_date: nil }

          assert_select "form#new_office_business_contract"
        end

        it 'does not duplicate the error message' do
          post_create attrs: { ending_date: nil }

          error_messages = css_select('div#error_explanation ul li').collect(&:text)

          assert_equal error_messages.uniq.count, error_messages.count
        end
      end

      describe 'when the ending_date is before the beginning_date' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: { ending_date: beginning_date - 10.days }
          end
        end

        it 'render the error' do
          post_create attrs: { ending_date: beginning_date - 10.days }

          assert_select "form#new_office_business_contract"
        end

        it 'does not duplicate the error message' do
          post_create attrs: { ending_date: beginning_date - 10.days }

          error_messages = css_select('div#error_explanation ul li').collect(&:text)

          assert_equal error_messages.uniq.count, error_messages.count
        end
      end

      describe 'when the establishment address is empty' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: { establishment_address_2: nil }
          end
        end

        it 'render the error' do
          post_create attrs: { establishment_address_2: nil }

          assert_select "form#new_office_business_contract"
        end

        it 'does not duplicate the error message' do
          post_create attrs: { establishment_address_2: nil }

          error_messages = css_select('div#error_explanation ul li').collect(&:text)

          assert_equal error_messages.uniq.count, error_messages.count
        end
      end

      describe 'when the contact address is empty' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: { contact_address_2: nil }
          end
        end

        it 'render the error' do
          post_create attrs: { contact_address_2: nil }

          assert_select "form#new_office_business_contract"
        end

        it 'does not duplicate the error message' do
          post_create attrs: { contact_address_2: nil }

          error_messages = css_select('div#error_explanation ul li').collect(&:text)

          assert_equal error_messages.uniq.count, error_messages.count
        end
      end

      describe 'when the contact address is empty' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: { contact_address_2: nil }
          end
        end

        it 'render the error' do
          post_create attrs: { contact_address_2: nil }

          assert_select "form#new_office_business_contract"
        end

        it 'does not duplicate the error message' do
          post_create attrs: { contact_address_2: nil }

          error_messages = css_select('div#error_explanation ul li').collect(&:text)

          assert_equal error_messages.uniq.count, error_messages.count
        end
      end

      describe 'when the contact zip code is empty' do
        describe 'when the country is France' do
          it 'does not create anything in database' do
            assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
              post_create attrs: { contact_zip_code: nil }
            end
          end

          it 'render the error' do
            post_create attrs: { contact_zip_code: nil }

            assert_select "form#new_office_business_contract"
          end

          it 'does not duplicate the error message' do
            post_create attrs: { contact_zip_code: nil }

            error_messages = css_select('div#error_explanation ul li').collect(&:text)

            assert_equal error_messages.uniq.count, error_messages.count
          end
        end

        describe 'when the country is not France' do
          it 'creates the entry in database' do
            assert_difference 'Goxygene::OfficeBusinessContract.count' do
              post_create attrs: { establishment_id: nil, contact_country_id: country_not_france.id, contact_zip_code: nil }
            end
          end

          it 'sets the right values' do
            post_create attrs: { establishment_id: nil, contact_country_id: country_not_france.id, contact_zip_code: nil }

            office_business_contract = consultant.office_business_contracts.last

            assert_equal '',                                      office_business_contract.establishment_vat_number.to_s.strip
            assert_equal new_siret,                                      office_business_contract.establishment_siret.to_s.strip

            assert_equal establishment_name,                      office_business_contract.establishment_name
            assert_equal establishment.contact_datum.address_2,   office_business_contract.establishment_address_2
            assert_equal establishment.contact_datum.zip_code,    office_business_contract.establishment_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.establishment_city
            assert_equal establishment.contact_datum.country_id,  office_business_contract.establishment_country_id
            assert_equal establishment.contact_datum.phone,       office_business_contract.establishment_phone

            assert_equal last_name,                               office_business_contract.contact_last_name
            assert_equal first_name,                              office_business_contract.contact_first_name
            assert_equal contact_type.id,                         office_business_contract.contact_contact_type.id
            assert_equal contact_role.id,                         office_business_contract.contact_contact_role.id
            assert_equal country_not_france.id,                   office_business_contract.contact_country_id
            assert_nil                                            office_business_contract.contact_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.contact_city
            assert_equal establishment.contact_datum.phone,       office_business_contract.contact_phone
            assert_equal establishment.contact_datum.email,       office_business_contract.contact_email

            assert_equal mission_subject,                         office_business_contract.mission_subject
            assert_equal beginning_date,                          office_business_contract.begining_date
            assert_equal ending_date,                             office_business_contract.ending_date
            assert_equal time_length,                             office_business_contract.time_length
            assert_equal order_amount,                            office_business_contract.order_amount
            assert_equal daily_order_amount,                      office_business_contract.daily_order_amount
            assert_equal consultant_comment,                      office_business_contract.consultant_comment
            assert_equal expenses_comment,                        office_business_contract.expenses_comment
            assert_equal expenses_payback_comment,                office_business_contract.expenses_payback_comment
            assert_equal contract_handling_comment,               office_business_contract.contract_handling_comment
            assert_equal notice_period,                           office_business_contract.notice_period
          end

          it 'responds with success' do
            post_create attrs: { establishment_id: nil, contact_country_id: country_not_france.id, contact_zip_code: nil }

            assert_response :success
          end

          it 'renders the preview form' do
            post_create attrs: { establishment_id: nil, contact_country_id: country_not_france.id, contact_zip_code: nil }

            assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
          end

          it 'includes the client name in the preview form' do
            post_create attrs: { establishment_id: nil, contact_country_id: country_not_france.id, contact_zip_code: nil }

            assert_select "div.establishment_name", establishment_name
          end

          it 'includes the contract VAT rate in the preview form' do
            post_create attrs: { establishment_id: nil, contact_country_id: country_not_france.id, contact_zip_code: nil }

            assert_select "div.vat_rate", "#{vat.label} - #{vat.rate}%"
          end
        end
      end

      describe 'when the contact first name is empty' do
        it 'creates an entry in database' do
          assert_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: { contact_first_name: nil }
          end
        end

        it 'render the page' do
          post_create attrs: { contact_first_name: nil }

          assert_response :success
        end

        it 'renders the preview form' do
          post_create attrs: { establishment_id: nil, contact_country_id: country_not_france.id, contact_zip_code: nil }

          assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
        end

        it 'includes the client name in the preview form' do
          post_create attrs: { establishment_id: nil, contact_country_id: country_not_france.id, contact_zip_code: nil }

          assert_select "div.establishment_name", establishment_name
        end
      end

      describe 'when the contact last name is empty' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: { contact_last_name: nil }
          end
        end

        it 'render the error' do
          post_create attrs: { contact_last_name: nil }

          assert_select "form#new_office_business_contract"
        end

        it 'does not duplicate the error message' do
          post_create attrs: { contact_last_name: nil }

          error_messages = css_select('div#error_explanation ul li').collect(&:text)

          assert_equal error_messages.uniq.count, error_messages.count
        end
      end

      describe 'when the time_length is empty' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: { time_length: nil }
          end
        end

        it 'render the error' do
          post_create attrs: { time_length: nil }

          assert_select "form#new_office_business_contract"
        end

        it 'does not duplicate the error message' do
          post_create attrs: { time_length: nil }

          error_messages = css_select('div#error_explanation ul li').collect(&:text)

          assert_equal error_messages.uniq.count, error_messages.count
        end
      end

      describe 'when the time length exceed the real days count between begin and end date' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: {
              time_length:   10,
              begining_date: Date.current + 2.days,
              ending_date:   Date.current + 5.days
            }
          end
        end

        it 'render the error' do
          post_create attrs: {
            time_length:   10,
            begining_date: Date.current + 2.days,
            ending_date:   Date.current + 5.days
          }

          assert_select "form#new_office_business_contract"
        end

        it 'does not duplicate the error message' do
          post_create attrs: {
            time_length:   10,
            begining_date: Date.current + 2.days,
            ending_date:   Date.current + 5.days
          }

          error_messages = css_select('div#error_explanation ul li').collect(&:text)

          assert_equal error_messages.uniq.count, error_messages.count
        end
      end

      describe 'when the ordered amount is below minimal' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: {
              daily_order_amount: 69,
              time_length:        1,
              order_amount:       69
            }
          end
        end

        it 'render the error' do
          post_create attrs: {
            daily_order_amount: 69,
            time_length:        1,
            order_amount:       69
          }

          assert_select "form#new_office_business_contract"
        end

        it 'does not duplicate the error message' do
          post_create attrs: {
            daily_order_amount: 69,
            time_length:        1,
            order_amount:       69
          }

          error_messages = css_select('div#error_explanation ul li').collect(&:text)

          assert_equal error_messages.uniq.count, error_messages.count
        end

        it 'includes the right error message' do
          post_create attrs: {
            daily_order_amount: 69,
            time_length:        1,
            order_amount:       69
          }

          error_messages = css_select('div#error_explanation ul li').collect(&:text)

          assert error_messages.one? { |m| m.match /doit être supérieure au minimum de/ }
        end
      end

      describe 'when the daily order amount is right above minimum' do
        it 'creates the entry in database' do
          assert_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: {
              daily_order_amount: 250,
              time_length:        1,
              order_amount:       250
            }
          end
        end

        it 'responds with success' do
          post_create attrs: {
            daily_order_amount: 250,
            time_length:        1,
            order_amount:       250
          }

          assert_response :success
        end

        it 'renders the preview form' do
          post_create attrs: {
            daily_order_amount: 250,
            time_length:        1,
            order_amount:       250
          }

          assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
        end
      end

      describe 'when all the fields are valid' do
        describe 'when creating a new contact' do
          before do
            establishment.update_columns siret: nil
            establishment.reload
          end

          it 'creates the entry in database' do
            assert_difference 'Goxygene::OfficeBusinessContract.count' do
              post_create attrs: { establishment_id: establishment.id }
            end
          end


          it 'does not create a new establishment' do
            assert_no_difference 'Goxygene::Establishment.count' do
              post_create attrs: { establishment_id: establishment.id }
            end
          end

          it 'does not create a temporary establishment entry' do
            assert_difference 'Goxygene::OfficeTempEstablishment.count' do
              post_create attrs: { establishment_id: establishment.id }
            end
          end

          it 'creates a new establishment contact' do
            assert_difference 'Goxygene::EstablishmentContact.count' do
              post_create attrs: { establishment_id: establishment.id }
            end
          end

          it 'sets the right values' do
            post_create attrs: { establishment_id: establishment.id }

            office_business_contract = consultant.office_business_contracts.last

            assert_equal '',                                      office_business_contract.establishment_vat_number.to_s.strip
            assert_equal '',                                      office_business_contract.establishment_siret.to_s.strip

            assert_equal establishment.name,                      office_business_contract.establishment_name
            assert_equal establishment.contact_datum.address_2,   office_business_contract.establishment_address_2
            assert_equal establishment.contact_datum.zip_code,    office_business_contract.establishment_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.establishment_city
            assert_equal establishment.contact_datum.country_id,  office_business_contract.establishment_country_id
            assert_equal establishment.contact_datum.phone,       office_business_contract.establishment_phone

            assert_equal last_name,                               office_business_contract.contact_last_name
            assert_equal first_name,                              office_business_contract.contact_first_name
            assert_equal contact_type.id,                         office_business_contract.contact_contact_type.id
            assert_equal contact_role.id,                         office_business_contract.contact_contact_role.id
            assert_equal establishment.contact_datum.country_id,  office_business_contract.contact_country_id
            assert_equal establishment.contact_datum.zip_code,    office_business_contract.contact_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.contact_city
            assert_equal establishment.contact_datum.phone,       office_business_contract.contact_phone
            assert_equal establishment.contact_datum.email,       office_business_contract.contact_email

            assert_equal mission_subject,                         office_business_contract.mission_subject
            assert_equal beginning_date,                          office_business_contract.begining_date
            assert_equal ending_date,                             office_business_contract.ending_date
            assert_equal time_length,                             office_business_contract.time_length
            assert_equal order_amount,                            office_business_contract.order_amount
            assert_equal daily_order_amount,                      office_business_contract.daily_order_amount
            assert_equal consultant_comment,                      office_business_contract.consultant_comment
            assert_equal expenses_comment,                        office_business_contract.expenses_comment
            assert_equal expenses_payback_comment,                office_business_contract.expenses_payback_comment
            assert_equal contract_handling_comment,               office_business_contract.contract_handling_comment
            assert_equal notice_period,                           office_business_contract.notice_period
          end

          it 'responds with success' do
            post_create attrs: { establishment_id: establishment.id }

            assert_response :success
          end

          it 'renders the preview form' do
            post_create attrs: { establishment_id: establishment.id }

            assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
          end

          it 'includes the client name in the preview form' do
            post_create attrs: { establishment_id: establishment.id }

            assert_select "div.establishment_name", establishment.name
          end

          it 'includes the VAT rate in the preview form' do
            post_create attrs: { establishment_id: establishment.id }

            assert_select "div.vat_rate", "#{vat.label} - #{vat.rate}%"
          end
        end
        describe 'when creating a new client' do
          describe 'when Manageo API is failing' do
            before do
              mock = Minitest::Mock.new

              def mock.establishments(attrs = {})
                raise "Manageo API returned 402 with"
              end

              Manageo::Company = mock
            end

            it 'creates the entry in database' do
              assert_difference 'Goxygene::OfficeBusinessContract.count' do
                post_create attrs: { establishment_id: nil, establishment_siret: new_siret }
              end
            end


            it 'does not create a new establishment' do
              assert_no_difference 'Goxygene::Establishment.count' do
                post_create attrs: { establishment_id: nil, establishment_siret: new_siret }
              end
            end

            it 'creates a temporary establishment entry' do
              assert_difference 'Goxygene::OfficeTempEstablishment.count' do
                post_create attrs: { establishment_id: nil, establishment_siret: new_siret }
              end
            end

            it 'does not create a new establishment contact' do
              assert_no_difference 'Goxygene::EstablishmentContact.count' do
                post_create attrs: { establishment_id: nil, establishment_siret: new_siret }
              end
            end

            it 'sets the right values' do
              post_create attrs: { establishment_id: nil, establishment_siret: new_siret }

              office_business_contract = consultant.office_business_contracts.last

              assert_equal '',                                      office_business_contract.establishment_vat_number.to_s.strip
              assert_equal new_siret,                               office_business_contract.establishment_siret.to_s.strip

              assert_equal establishment_name,                      office_business_contract.establishment_name
              assert_equal establishment.contact_datum.address_2,   office_business_contract.establishment_address_2
              assert_equal establishment.contact_datum.zip_code,    office_business_contract.establishment_zip_code
              assert_equal establishment.contact_datum.city,        office_business_contract.establishment_city
              assert_equal establishment.contact_datum.country_id,  office_business_contract.establishment_country_id
              assert_equal establishment.contact_datum.phone,       office_business_contract.establishment_phone

              assert_equal last_name,                               office_business_contract.contact_last_name
              assert_equal first_name,                              office_business_contract.contact_first_name
              assert_equal contact_type.id,                         office_business_contract.contact_contact_type.id
              assert_equal contact_role.id,                         office_business_contract.contact_contact_role.id
              assert_equal establishment.contact_datum.country_id,  office_business_contract.contact_country_id
              assert_equal establishment.contact_datum.zip_code,    office_business_contract.contact_zip_code
              assert_equal establishment.contact_datum.city,        office_business_contract.contact_city
              assert_equal establishment.contact_datum.phone,       office_business_contract.contact_phone
              assert_equal establishment.contact_datum.email,       office_business_contract.contact_email

              assert_equal mission_subject,                         office_business_contract.mission_subject
              assert_equal beginning_date,                          office_business_contract.begining_date
              assert_equal ending_date,                             office_business_contract.ending_date
              assert_equal time_length,                             office_business_contract.time_length
              assert_equal order_amount,                            office_business_contract.order_amount
              assert_equal daily_order_amount,                      office_business_contract.daily_order_amount
              assert_equal consultant_comment,                      office_business_contract.consultant_comment
              assert_equal expenses_comment,                        office_business_contract.expenses_comment
              assert_equal expenses_payback_comment,                office_business_contract.expenses_payback_comment
              assert_equal contract_handling_comment,               office_business_contract.contract_handling_comment
              assert_equal notice_period,                           office_business_contract.notice_period
            end

            it 'responds with success' do
              post_create attrs: { establishment_id: nil, establishment_siret: new_siret }

              assert_response :success
            end

            it 'renders the preview form' do
              post_create attrs: { establishment_id: nil, establishment_siret: new_siret }

              assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
            end

            it 'includes the client name in the preview form' do
              post_create attrs: { establishment_id: nil, establishment_siret: new_siret }

              assert_select "div.establishment_name", establishment_name
            end

            it 'includes the VAT rate in the preview form' do
              post_create attrs: { establishment_id: nil, establishment_siret: new_siret }

              assert_select "div.vat_rate", "#{vat.label} - #{vat.rate}%"
            end

            describe 'when siret contains spaces' do
              it 'creates the entry in database' do
                assert_difference 'Goxygene::OfficeBusinessContract.count' do
                  post_create attrs: { establishment_id: nil, establishment_siret: siret_with_spaces }
                end
              end


              it 'does not create a new establishment' do
                assert_no_difference 'Goxygene::Establishment.count' do
                  post_create attrs: { establishment_id: nil, establishment_siret: siret_with_spaces }
                end
              end

              it 'creates a temporary establishment entry' do
                assert_difference 'Goxygene::OfficeTempEstablishment.count' do
                  post_create attrs: { establishment_id: nil, establishment_siret: siret_with_spaces }
                end
              end

              it 'does not create a new establishment contact' do
                assert_no_difference 'Goxygene::EstablishmentContact.count' do
                  post_create attrs: { establishment_id: nil, establishment_siret: siret_with_spaces }
                end
              end

              it 'sets the right values' do
                post_create attrs: { establishment_id: nil, establishment_siret: siret_with_spaces }

                office_business_contract = consultant.office_business_contracts.last

                assert_equal '',                                      office_business_contract.establishment_vat_number.to_s.strip
                assert_equal siret_with_spaces.delete("^0-9"),        office_business_contract.establishment_siret.to_s.strip

                assert_equal establishment_name,                      office_business_contract.establishment_name
                assert_equal establishment.contact_datum.address_2,   office_business_contract.establishment_address_2
                assert_equal establishment.contact_datum.zip_code,    office_business_contract.establishment_zip_code
                assert_equal establishment.contact_datum.city,        office_business_contract.establishment_city
                assert_equal establishment.contact_datum.country_id,  office_business_contract.establishment_country_id
                assert_equal establishment.contact_datum.phone,       office_business_contract.establishment_phone

                assert_equal last_name,                               office_business_contract.contact_last_name
                assert_equal first_name,                              office_business_contract.contact_first_name
                assert_equal contact_type.id,                         office_business_contract.contact_contact_type.id
                assert_equal contact_role.id,                         office_business_contract.contact_contact_role.id
                assert_equal establishment.contact_datum.country_id,  office_business_contract.contact_country_id
                assert_equal establishment.contact_datum.zip_code,    office_business_contract.contact_zip_code
                assert_equal establishment.contact_datum.city,        office_business_contract.contact_city
                assert_equal establishment.contact_datum.phone,       office_business_contract.contact_phone
                assert_equal establishment.contact_datum.email,       office_business_contract.contact_email

                assert_equal mission_subject,                         office_business_contract.mission_subject
                assert_equal beginning_date,                          office_business_contract.begining_date
                assert_equal ending_date,                             office_business_contract.ending_date
                assert_equal time_length,                             office_business_contract.time_length
                assert_equal order_amount,                            office_business_contract.order_amount
                assert_equal daily_order_amount,                      office_business_contract.daily_order_amount
                assert_equal consultant_comment,                      office_business_contract.consultant_comment
                assert_equal expenses_comment,                        office_business_contract.expenses_comment
                assert_equal expenses_payback_comment,                office_business_contract.expenses_payback_comment
                assert_equal contract_handling_comment,               office_business_contract.contract_handling_comment
                assert_equal notice_period,                           office_business_contract.notice_period
              end

              it 'responds with success' do
                post_create attrs: { establishment_id: nil, establishment_siret: siret_with_spaces }

                assert_response :success
              end

              it 'renders the preview form' do
                post_create attrs: { establishment_id: nil, establishment_siret: siret_with_spaces }

                assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
              end

              it 'includes the client name in the preview form' do
                post_create attrs: { establishment_id: nil, establishment_siret: siret_with_spaces }

                assert_select "div.establishment_name", establishment_name
              end

              it 'includes the VAT rate in the preview form' do
                post_create attrs: { establishment_id: nil, establishment_siret: siret_with_spaces }

                assert_select "div.vat_rate", "#{vat.label} - #{vat.rate}%"
              end
            end
          end

          describe 'when adding a new establishment to an existing customer' do
            let(:siret) { '51817284600025' }

            before do
              Manageo::Company = Minitest::Mock.new

              Manageo::Company.expect(
                :establishments,
                [
                  OpenStruct.new(actif: 1, siret: siret[0..8], nic: 25, raisonSociale: new_name, adresse: new_address, codePostal: new_zip_code, ville: new_city)
                ],
                [ { siren: siret[0..8] } ]
              )
            end

            it 'must share the same siren' do
              assert_equal siret[0..8], establishment.siret[0..8]
            end

            it 'responds with success' do
              post_create attrs: { establishment_id: nil, establishment_siret: siret }

              assert_response :success
            end

            it 'creates a new establishment' do
              assert_difference 'Goxygene::Establishment.count' do
                skip
                post_create attrs: { establishment_id: nil, establishment_siret: siret }
              end
            end

            it 'links the new establishment to the existing customer' do
              skip
            end
          end


          describe 'when creating an establishment through Manageo' do
            before do
              Manageo::Company = Minitest::Mock.new

              Manageo::Company.expect(
                :establishments,
                [
                  OpenStruct.new(actif: 1, siren: new_siret[0..8], nic: new_siret[9..14].to_i, raisonSociale: new_name,           adresse: new_address, codePostal: new_zip_code, ville: new_city),
                  OpenStruct.new(actif: 0, siren: new_siret[0..8], nic: new_siret[9..14].to_i, raisonSociale: establishment_name, adresse: new_address, codePostal: new_zip_code, ville: new_city)
                ],
                [ { siren: new_siret[0..8] } ]
              )
            end

            it 'searches the siren from Manageo' do
              post_create attrs: { establishment_id: nil, establishment_siret: new_siret }

              assert_mock Manageo::Company
            end

            it 'creates the entry in database' do
              assert_difference 'Goxygene::OfficeBusinessContract.count' do
                post_create attrs: { establishment_id: nil, establishment_siret: new_siret }
              end
            end

            it 'creates a new establishment' do
              assert_difference 'Goxygene::Establishment.count' do
                post_create attrs: { establishment_id: nil, establishment_siret: new_siret }
              end
            end

            it 'does not create a temporary establishment entry' do
              assert_no_difference 'Goxygene::OfficeTempEstablishment.count' do
                post_create attrs: { establishment_id: nil, establishment_siret: new_siret }
              end
            end

            it 'creates a new establishment contact' do
              assert_difference 'Goxygene::EstablishmentContact.count' do
                post_create attrs: { establishment_id: nil, establishment_siret: new_siret }
              end
            end

            it 'sets the right values' do
              post_create attrs: { establishment_id: nil, establishment_siret: new_siret }

              office_business_contract = consultant.office_business_contracts.last

              assert_equal '',                                      office_business_contract.establishment_vat_number.to_s.strip
              assert_equal new_siret,                               office_business_contract.establishment_siret.to_s.strip

              assert_equal establishment_name,                      office_business_contract.establishment_name
              assert_equal establishment.contact_datum.address_2,   office_business_contract.establishment_address_2
              assert_equal establishment.contact_datum.zip_code,    office_business_contract.establishment_zip_code
              assert_equal establishment.contact_datum.city,        office_business_contract.establishment_city
              assert_equal establishment.contact_datum.country_id,  office_business_contract.establishment_country_id
              assert_equal establishment.contact_datum.phone,       office_business_contract.establishment_phone

              assert_equal last_name,                               office_business_contract.contact_last_name
              assert_equal first_name,                              office_business_contract.contact_first_name
              assert_equal contact_type.id,                         office_business_contract.contact_contact_type.id
              assert_equal contact_role.id,                         office_business_contract.contact_contact_role.id
              assert_equal establishment.contact_datum.country_id,  office_business_contract.contact_country_id
              assert_equal establishment.contact_datum.zip_code,    office_business_contract.contact_zip_code
              assert_equal establishment.contact_datum.city,        office_business_contract.contact_city
              assert_equal establishment.contact_datum.phone,       office_business_contract.contact_phone
              assert_equal establishment.contact_datum.email,       office_business_contract.contact_email

              assert_equal mission_subject,                         office_business_contract.mission_subject
              assert_equal beginning_date,                          office_business_contract.begining_date
              assert_equal ending_date,                             office_business_contract.ending_date
              assert_equal time_length,                             office_business_contract.time_length
              assert_equal order_amount,                            office_business_contract.order_amount
              assert_equal daily_order_amount,                      office_business_contract.daily_order_amount
              assert_equal consultant_comment,                      office_business_contract.consultant_comment
              assert_equal expenses_comment,                        office_business_contract.expenses_comment
              assert_equal expenses_payback_comment,                office_business_contract.expenses_payback_comment
              assert_equal contract_handling_comment,               office_business_contract.contract_handling_comment
              assert_equal notice_period,                           office_business_contract.notice_period
            end

            it 'responds with success' do
              post_create attrs: { establishment_id: nil, establishment_siret: new_siret }

              assert_response :success
            end

            it 'renders the preview form' do
              post_create attrs: { establishment_id: nil, establishment_siret: new_siret }

              assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
            end

            it 'includes the client name in the preview form' do
              post_create attrs: { establishment_id: nil, establishment_siret: new_siret }

              assert_select "div.establishment_name", establishment_name
            end

            it 'includes the VAT rate in the preview form' do
              post_create attrs: { establishment_id: nil, establishment_siret: new_siret }

              assert_select "div.vat_rate", "#{vat.label} - #{vat.rate}%"
            end
          end

          describe 'when using a siret matching an existing establishment' do
            it 'must have a siret' do
              assert_not_empty establishment.siret
            end

            it 'creates the entry in database' do
              assert_difference 'Goxygene::OfficeBusinessContract.count' do
                post_create attrs: { establishment_id: nil, establishment_siret: establishment.siret }
              end
            end

            it 'does not create a new establishment' do
              assert_no_difference 'Goxygene::Establishment.count' do
                post_create attrs: { establishment_id: nil, establishment_siret: establishment.siret }
              end
            end

            it 'does not create a temporary establishment entry' do
              assert_no_difference 'Goxygene::OfficeTempEstablishment.count' do
                post_create attrs: { establishment_id: nil, establishment_siret: establishment.siret }
              end
            end

            it 'sets the establishment id' do
              post_create attrs: { establishment_id: nil, establishment_siret: establishment.siret }

              assert_equal establishment, consultant.office_business_contracts.last.establishment
            end

            it 'creates a new establishment contact' do
              assert_difference 'Goxygene::EstablishmentContact.count' do
                post_create attrs: { establishment_id: nil, establishment_siret: establishment.siret }
              end
            end

            it 'sets the right values' do
              post_create attrs: { establishment_id: nil, establishment_siret: establishment.siret }

              office_business_contract = consultant.office_business_contracts.last

              assert_equal '',                                      office_business_contract.establishment_vat_number.to_s.strip
              assert_equal establishment.siret,                     office_business_contract.establishment_siret.to_s.strip

              assert_equal establishment.name,                      office_business_contract.establishment_name
              assert_equal establishment.contact_datum.address_2,   office_business_contract.establishment_address_2
              assert_equal establishment.contact_datum.zip_code,    office_business_contract.establishment_zip_code
              assert_equal establishment.contact_datum.city,        office_business_contract.establishment_city
              assert_equal establishment.contact_datum.country_id,  office_business_contract.establishment_country_id
              assert_equal establishment.contact_datum.phone,       office_business_contract.establishment_phone

              assert_equal last_name,                               office_business_contract.contact_last_name
              assert_equal first_name,                              office_business_contract.contact_first_name
              assert_equal contact_type.id,                         office_business_contract.contact_contact_type.id
              assert_equal contact_role.id,                         office_business_contract.contact_contact_role.id
              assert_equal establishment.contact_datum.country_id,  office_business_contract.contact_country_id
              assert_equal establishment.contact_datum.zip_code,    office_business_contract.contact_zip_code
              assert_equal establishment.contact_datum.city,        office_business_contract.contact_city
              assert_equal establishment.contact_datum.phone,       office_business_contract.contact_phone
              assert_equal establishment.contact_datum.email,       office_business_contract.contact_email

              assert_equal mission_subject,                         office_business_contract.mission_subject
              assert_equal beginning_date,                          office_business_contract.begining_date
              assert_equal ending_date,                             office_business_contract.ending_date
              assert_equal time_length,                             office_business_contract.time_length
              assert_equal order_amount,                            office_business_contract.order_amount
              assert_equal daily_order_amount,                      office_business_contract.daily_order_amount
              assert_equal consultant_comment,                      office_business_contract.consultant_comment
              assert_equal expenses_comment,                        office_business_contract.expenses_comment
              assert_equal expenses_payback_comment,                office_business_contract.expenses_payback_comment
              assert_equal contract_handling_comment,               office_business_contract.contract_handling_comment
              assert_equal notice_period,                           office_business_contract.notice_period
            end

            it 'responds with success' do
              post_create attrs: { establishment_id: nil, establishment_siret: establishment.siret }

              assert_response :success
            end

            it 'renders the preview form' do
              post_create attrs: { establishment_id: nil, establishment_siret: establishment.siret }

              assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
            end

            it 'includes the client name in the preview form' do
              post_create attrs: { establishment_id: nil, establishment_siret: establishment.siret }

              assert_select "div.establishment_name", establishment.name
            end

            it 'includes the VAT rate in the preview form' do
              post_create attrs: { establishment_id: nil, establishment_siret: establishment.siret }

              assert_select "div.vat_rate", "#{vat.label} - #{vat.rate}%"
            end
          end

          it 'creates the entry in database' do
            assert_difference 'Goxygene::OfficeBusinessContract.count' do
              post_create attrs: { establishment_id: nil }
            end
          end

          it 'sets the right values' do
            post_create attrs: { establishment_id: nil }

            office_business_contract = consultant.office_business_contracts.last

            assert_equal '',                                      office_business_contract.establishment_vat_number.to_s.strip
            assert_equal new_siret,                                   office_business_contract.establishment_siret.to_s.strip

            assert_equal establishment_name,                      office_business_contract.establishment_name
            assert_equal establishment.contact_datum.address_2,   office_business_contract.establishment_address_2
            assert_equal establishment.contact_datum.zip_code,    office_business_contract.establishment_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.establishment_city
            assert_equal establishment.contact_datum.country_id,  office_business_contract.establishment_country_id
            assert_equal establishment.contact_datum.phone,       office_business_contract.establishment_phone

            assert_equal last_name,                               office_business_contract.contact_last_name
            assert_equal first_name,                              office_business_contract.contact_first_name
            assert_equal contact_type.id,                         office_business_contract.contact_contact_type.id
            assert_equal contact_role.id,                         office_business_contract.contact_contact_role.id
            assert_equal establishment.contact_datum.country_id,  office_business_contract.contact_country_id
            assert_equal establishment.contact_datum.zip_code,    office_business_contract.contact_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.contact_city
            assert_equal establishment.contact_datum.phone,       office_business_contract.contact_phone
            assert_equal establishment.contact_datum.email,       office_business_contract.contact_email

            assert_equal mission_subject,                         office_business_contract.mission_subject
            assert_equal beginning_date,                          office_business_contract.begining_date
            assert_equal ending_date,                             office_business_contract.ending_date
            assert_equal time_length,                             office_business_contract.time_length
            assert_equal order_amount,                            office_business_contract.order_amount
            assert_equal daily_order_amount,                      office_business_contract.daily_order_amount
            assert_equal consultant_comment,                      office_business_contract.consultant_comment
            assert_equal expenses_comment,                        office_business_contract.expenses_comment
            assert_equal expenses_payback_comment,                office_business_contract.expenses_payback_comment
            assert_equal contract_handling_comment,               office_business_contract.contract_handling_comment
            assert_equal notice_period,                           office_business_contract.notice_period
          end

          it 'responds with success' do
            post_create attrs: { establishment_id: nil }

            assert_response :success
          end

          it 'renders the preview form' do
            post_create attrs: { establishment_id: nil }

            assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
          end

          it 'includes the client name in the preview form' do
            post_create attrs: { establishment_id: nil }

            assert_select "div.establishment_name", establishment_name
          end

          it 'includes the VAT rate in the preview form' do
            post_create attrs: { establishment_id: nil }

            assert_select "div.vat_rate", "#{vat.label} - #{vat.rate}%"
          end
        end

        describe 'with some attachments' do
          it 'creates the entry in database' do
            assert_difference 'Goxygene::OfficeBusinessContract.count' do
              post_create attrs: { establishment_id: establishment.id },
                          attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]
            end
          end

          it 'creates attachments entries in the database' do
            assert_difference 'Goxygene::Document.count' do
              assert_difference 'Goxygene::OfficeBusinessContractsDocument.count' do
                post_create attrs: { establishment_id: establishment.id },
                            attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]
              end
            end
          end

          it 'displays the list of attachments in the preview form'

          it 'sets the right values' do
            post_create attrs: { establishment_id: establishment.id },
                        attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]

            office_business_contract = consultant.office_business_contracts.last

            assert_equal establishment,                           office_business_contract.establishment
            assert_equal '',                                      office_business_contract.establishment_vat_number.to_s.strip
            assert_equal establishment.siret,                     office_business_contract.establishment_siret.to_s.strip

            assert_equal establishment.name,                      office_business_contract.establishment_name
            assert_equal establishment.contact_datum.address_2,   office_business_contract.establishment_address_2
            assert_equal establishment.contact_datum.zip_code,    office_business_contract.establishment_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.establishment_city
            assert_equal establishment.contact_datum.country_id,  office_business_contract.establishment_country_id
            assert_equal establishment.contact_datum.phone,       office_business_contract.establishment_phone

            assert_equal last_name,                               office_business_contract.contact_last_name
            assert_equal first_name,                              office_business_contract.contact_first_name
            assert_equal contact_type.id,                         office_business_contract.contact_contact_type.id
            assert_equal contact_role.id,                         office_business_contract.contact_contact_role.id
            assert_equal establishment.contact_datum.country_id,  office_business_contract.contact_country_id
            assert_equal establishment.contact_datum.zip_code,    office_business_contract.contact_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.contact_city
            assert_equal establishment.contact_datum.phone,       office_business_contract.contact_phone
            assert_equal establishment.contact_datum.email,       office_business_contract.contact_email

            assert_equal mission_subject,                         office_business_contract.mission_subject
            assert_equal beginning_date,                          office_business_contract.begining_date
            assert_equal ending_date,                             office_business_contract.ending_date
            assert_equal time_length,                             office_business_contract.time_length
            assert_equal order_amount,                            office_business_contract.order_amount
            assert_equal daily_order_amount,                      office_business_contract.daily_order_amount
            assert_equal consultant_comment,                      office_business_contract.consultant_comment
            assert_equal expenses_comment,                        office_business_contract.expenses_comment
            assert_equal expenses_payback_comment,                office_business_contract.expenses_payback_comment
            assert_equal contract_handling_comment,               office_business_contract.contract_handling_comment
            assert_equal notice_period,                           office_business_contract.notice_period
          end

          it 'responds with success' do
            post_create attrs: { establishment_id: establishment.id },
                        attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]

            assert_response :success
          end

          it 'renders the preview form' do
            post_create attrs: { establishment_id: establishment.id },
                        attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]

            assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
          end

          it 'includes the client name in the preview form' do
            post_create attrs: { establishment_id: establishment.id },
                        attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]

            assert_select "div.establishment_name", 'FTOPIA SAS'
          end

          it 'includes the VAT rate in the preview form' do
            post_create attrs: { establishment_id: establishment.id },
                        attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]

            assert_select "div.vat_rate", "#{vat.label} - #{vat.rate}%"
          end
        end

        describe 'when the contact is selected' do
          it 'creates the entry in database' do
            assert_difference 'Goxygene::OfficeBusinessContract.count' do
              post_create attrs: {
                establishment_id: establishment.id,
                establishment_contact_id: establishment_contact.id
              }
            end
          end

          it 'does not create a temporary entry' do
            assert_no_difference 'Goxygene::OfficeTempEstablishment.count' do
              post_create attrs: {
                establishment_id: establishment.id,
                establishment_contact_id: establishment_contact.id
              }
            end
          end

          it 'does not create a new contact entry' do
            assert_no_difference 'Goxygene::EstablishmentContact.count' do
              post_create attrs: {
                establishment_id: establishment.id,
                establishment_contact_id: establishment_contact.id
              }
            end
          end

          it 'does not create a new establishment' do
            assert_no_difference 'Goxygene::Establishment.count' do
              post_create attrs: {
                establishment_id: establishment.id,
                establishment_contact_id: establishment_contact.id
              }
            end
          end

          it 'sets the right values' do
            post_create attrs: {
                establishment_id: establishment.id,
                establishment_contact_id: establishment_contact.id
              }

            office_business_contract = consultant.office_business_contracts.last

            assert_equal establishment,                           office_business_contract.establishment
            assert_equal '',                                      office_business_contract.establishment_vat_number.to_s.strip
            assert_equal establishment.siret,                     office_business_contract.establishment_siret.to_s.strip

            assert_equal establishment.name,                      office_business_contract.establishment_name
            assert_equal establishment.contact_datum.address_2,   office_business_contract.establishment_address_2
            assert_equal establishment.contact_datum.zip_code,    office_business_contract.establishment_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.establishment_city
            assert_equal establishment.contact_datum.country_id,  office_business_contract.establishment_country_id
            assert_equal establishment.contact_datum.phone,       office_business_contract.establishment_phone

            assert_equal last_name,                               office_business_contract.contact_last_name
            assert_equal first_name,                              office_business_contract.contact_first_name
            assert_equal contact_type.id,                         office_business_contract.contact_contact_type.id
            assert_equal contact_role.id,                         office_business_contract.contact_contact_role.id
            assert_equal establishment.contact_datum.country_id,  office_business_contract.contact_country_id
            assert_equal establishment.contact_datum.zip_code,    office_business_contract.contact_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.contact_city
            assert_equal establishment.contact_datum.phone,       office_business_contract.contact_phone
            assert_equal establishment.contact_datum.email,       office_business_contract.contact_email

            assert_equal mission_subject,                         office_business_contract.mission_subject
            assert_equal beginning_date,                          office_business_contract.begining_date
            assert_equal ending_date,                             office_business_contract.ending_date
            assert_equal time_length,                             office_business_contract.time_length
            assert_equal order_amount,                            office_business_contract.order_amount
            assert_equal daily_order_amount,                      office_business_contract.daily_order_amount
            assert_equal consultant_comment,                      office_business_contract.consultant_comment
            assert_equal expenses_comment,                        office_business_contract.expenses_comment
            assert_equal expenses_payback_comment,                office_business_contract.expenses_payback_comment
            assert_equal contract_handling_comment,               office_business_contract.contract_handling_comment
            assert_equal notice_period,                           office_business_contract.notice_period
          end

          it 'responds with success' do
            post_create attrs: {
                establishment_id: establishment.id,
                establishment_contact_id: establishment_contact.id
              }

            assert_response :success
          end

          it 'renders the preview form' do
            post_create attrs: {
                establishment_id: establishment.id,
                establishment_contact_id: establishment_contact.id
              }

            assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
          end

          it 'includes the client name in the preview form' do
            post_create attrs: {
                establishment_id: establishment.id,
                establishment_contact_id: establishment_contact.id
              }

            assert_select "div.establishment_name", 'FTOPIA SAS'
          end
        end

        describe 'when the contact is edited' do
          it 'creates the entry in database' do
            assert_difference 'Goxygene::OfficeBusinessContract.count' do
              post_create attrs: {
                establishment_id: establishment.id,
                establishment_contact_id: establishment_contact.id,
                contact_address_2:new_address,
                contact_city:     new_city,
                contact_zip_code: new_zip_code
              }
            end
          end

          it 'does not create a temporary entry' do
            assert_no_difference 'Goxygene::OfficeTempEstablishment.count' do
              post_create attrs: {
                establishment_id: establishment.id,
                establishment_contact_id: establishment_contact.id,
                contact_address_2:new_address,
                contact_city:     new_city,
                contact_zip_code: new_zip_code
              }
            end
          end

          it 'does not create a new contact entry' do
            assert_no_difference 'Goxygene::EstablishmentContact.count' do
              post_create attrs: {
                establishment_id: establishment.id,
                establishment_contact_id: establishment_contact.id,
                contact_address_2:new_address,
                contact_city:     new_city,
                contact_zip_code: new_zip_code
              }
            end
          end

          it 'does not create a new establishment' do
            assert_no_difference 'Goxygene::Establishment.count' do
              post_create attrs: {
                establishment_id: establishment.id,
                establishment_contact_id: establishment_contact.id,
                contact_address_2:new_address,
                contact_city:     new_city,
                contact_zip_code: new_zip_code
              }
            end
          end

          it 'sets the right values' do
            post_create attrs: {
                establishment_id: establishment.id,
                establishment_contact_id: establishment_contact.id,
                contact_address_2:new_address,
                contact_city:     new_city,
                contact_zip_code: new_zip_code
              }

            office_business_contract = consultant.office_business_contracts.last

            assert_equal establishment,                           office_business_contract.establishment
            assert_equal '',                                      office_business_contract.establishment_vat_number.to_s.strip
            assert_equal establishment.siret,                     office_business_contract.establishment_siret.to_s.strip

            assert_equal establishment.name,                      office_business_contract.establishment_name
            assert_equal establishment.contact_datum.address_2,   office_business_contract.establishment_address_2
            assert_equal establishment.contact_datum.zip_code,    office_business_contract.establishment_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.establishment_city
            assert_equal establishment.contact_datum.country_id,  office_business_contract.establishment_country_id
            assert_equal establishment.contact_datum.phone,       office_business_contract.establishment_phone

            assert_equal last_name,                               office_business_contract.contact_last_name
            assert_equal first_name,                              office_business_contract.contact_first_name
            assert_equal contact_type.id,                         office_business_contract.contact_contact_type.id
            assert_equal contact_role.id,                         office_business_contract.contact_contact_role.id
            assert_equal 1,                                       office_business_contract.contact_country_id
            assert_equal new_zip_code,                            office_business_contract.contact_zip_code
            assert_equal new_city,                                office_business_contract.contact_city
            assert_equal establishment.contact_datum.phone,       office_business_contract.contact_phone
            assert_equal establishment.contact_datum.email,       office_business_contract.contact_email

            assert_equal mission_subject,                         office_business_contract.mission_subject
            assert_equal beginning_date,                          office_business_contract.begining_date
            assert_equal ending_date,                             office_business_contract.ending_date
            assert_equal time_length,                             office_business_contract.time_length
            assert_equal order_amount,                            office_business_contract.order_amount
            assert_equal daily_order_amount,                      office_business_contract.daily_order_amount
            assert_equal consultant_comment,                      office_business_contract.consultant_comment
            assert_equal expenses_comment,                        office_business_contract.expenses_comment
            assert_equal expenses_payback_comment,                office_business_contract.expenses_payback_comment
            assert_equal contract_handling_comment,               office_business_contract.contract_handling_comment
            assert_equal notice_period,                           office_business_contract.notice_period
          end

          it 'responds with success' do
            post_create attrs: {
                establishment_id: establishment.id,
                establishment_contact_id: establishment_contact.id,
                contact_address_2:new_address,
                contact_city:     new_city,
                contact_zip_code: new_zip_code
              }

            assert_response :success
          end

          it 'renders the preview form' do
            post_create attrs: {
                establishment_id: establishment.id,
                establishment_contact_id: establishment_contact.id,
                contact_address_2:new_address,
                contact_city:     new_city,
                contact_zip_code: new_zip_code
              }

            assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
          end

          it 'includes the client name in the preview form' do
            post_create attrs: {
                establishment_id: establishment.id,
                establishment_contact_id: establishment_contact.id,
                contact_address_2:new_address,
                contact_city:     new_city,
                contact_zip_code: new_zip_code
              }

            assert_select "div.establishment_name", 'FTOPIA SAS'
          end
        end

        describe 'with a time based billing mode' do
          it 'creates the entry in database' do
            assert_difference 'Goxygene::OfficeBusinessContract.count' do
              post_create attrs: { establishment_id: establishment.id }
            end
          end

          it 'sets the right values' do
            post_create attrs: { establishment_id: establishment.id }

            office_business_contract = consultant.office_business_contracts.last

            assert_equal establishment,                           office_business_contract.establishment
            assert_equal '',                                      office_business_contract.establishment_vat_number.to_s.strip
            assert_equal establishment.siret,                     office_business_contract.establishment_siret.to_s.strip

            assert_equal establishment.name,                      office_business_contract.establishment_name
            assert_equal establishment.contact_datum.address_2,   office_business_contract.establishment_address_2
            assert_equal establishment.contact_datum.zip_code,    office_business_contract.establishment_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.establishment_city
            assert_equal establishment.contact_datum.country_id,  office_business_contract.establishment_country_id
            assert_equal establishment.contact_datum.phone,       office_business_contract.establishment_phone

            assert_equal last_name,                               office_business_contract.contact_last_name
            assert_equal first_name,                              office_business_contract.contact_first_name
            assert_equal contact_type.id,                         office_business_contract.contact_contact_type.id
            assert_equal contact_role.id,                         office_business_contract.contact_contact_role.id
            assert_equal establishment.contact_datum.country_id,  office_business_contract.contact_country_id
            assert_equal establishment.contact_datum.zip_code,    office_business_contract.contact_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.contact_city
            assert_equal establishment.contact_datum.phone,       office_business_contract.contact_phone
            assert_equal establishment.contact_datum.email,       office_business_contract.contact_email

            assert_equal mission_subject,                         office_business_contract.mission_subject
            assert_equal beginning_date,                          office_business_contract.begining_date
            assert_equal ending_date,                             office_business_contract.ending_date
            assert_equal time_length,                             office_business_contract.time_length
            assert_equal order_amount,                            office_business_contract.order_amount
            assert_equal daily_order_amount,                      office_business_contract.daily_order_amount
            assert_equal consultant_comment,                      office_business_contract.consultant_comment
            assert_equal expenses_comment,                        office_business_contract.expenses_comment
            assert_equal expenses_payback_comment,                office_business_contract.expenses_payback_comment
            assert_equal contract_handling_comment,               office_business_contract.contract_handling_comment
            assert_equal notice_period,                           office_business_contract.notice_period
          end

          it 'responds with success' do
            post_create attrs: { establishment_id: establishment.id }

            assert_response :success
          end

          it 'renders the preview form' do
            post_create attrs: { establishment_id: establishment.id }

            assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
          end

          it 'includes the client name in the preview form' do
            post_create attrs: { establishment_id: establishment.id }

            assert_select "div.establishment_name", 'FTOPIA SAS'
          end

          it 'includes the VAT rate in the preview form' do
            post_create attrs: { establishment_id: establishment.id }

            assert_select "div.vat_rate", "#{vat.label} - #{vat.rate}%"
          end
        end

        describe 'with a fixed price billing mode' do
          it 'creates the entry in database' do
            assert_difference 'Goxygene::OfficeBusinessContract.count' do
              post_create attrs: {
                establishment_id: establishment.id,
                billing_mode: 'fixed_price',
                time_length_approx: time_length,
                time_length: nil,
                daily_order_amount: nil
              }
            end
          end

          it 'sets the right values' do
            post_create attrs: {
              establishment_id: establishment.id,
              billing_mode: 'fixed_price',
              time_length_approx: time_length,
              time_length: nil,
              daily_order_amount: nil
            }

            office_business_contract = consultant.office_business_contracts.last

            assert_equal establishment,                           office_business_contract.establishment

            assert_equal '',                                      office_business_contract.establishment_vat_number.to_s.strip
            assert_equal establishment.siret,                     office_business_contract.establishment_siret.to_s.strip

            assert_equal establishment.name,                      office_business_contract.establishment_name
            assert_equal establishment.contact_datum.address_2,   office_business_contract.establishment_address_2
            assert_equal establishment.contact_datum.zip_code,    office_business_contract.establishment_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.establishment_city
            assert_equal establishment.contact_datum.country_id,  office_business_contract.establishment_country_id
            assert_equal establishment.contact_datum.phone,       office_business_contract.establishment_phone

            assert_equal last_name,                               office_business_contract.contact_last_name
            assert_equal first_name,                              office_business_contract.contact_first_name
            assert_equal contact_type.id,                         office_business_contract.contact_contact_type.id
            assert_equal contact_role.id,                         office_business_contract.contact_contact_role.id
            assert_equal establishment.contact_datum.country_id,  office_business_contract.contact_country_id
            assert_equal establishment.contact_datum.zip_code,    office_business_contract.contact_zip_code
            assert_equal establishment.contact_datum.city,        office_business_contract.contact_city
            assert_equal establishment.contact_datum.phone,       office_business_contract.contact_phone
            assert_equal establishment.contact_datum.email,       office_business_contract.contact_email

            assert_equal 'fixed_price',                           office_business_contract.billing_mode
            assert_equal mission_subject,                         office_business_contract.mission_subject
            assert_equal beginning_date,                          office_business_contract.begining_date
            assert_equal ending_date,                             office_business_contract.ending_date
            assert_equal time_length,                             office_business_contract.time_length
            assert_equal order_amount,                            office_business_contract.order_amount
            assert_equal 0,                                       office_business_contract.daily_order_amount
            assert_equal consultant_comment,                      office_business_contract.consultant_comment
            assert_equal expenses_comment,                        office_business_contract.expenses_comment
            assert_equal expenses_payback_comment,                office_business_contract.expenses_payback_comment
            assert_equal contract_handling_comment,               office_business_contract.contract_handling_comment
            assert_equal notice_period,                           office_business_contract.notice_period
          end

          it 'renders the preview form' do
            post_create attrs: {
              establishment_id: establishment.id,
              billing_mode: 'fixed_price',
              time_length_approx: time_length,
              time_length: nil,
              daily_order_amount: nil
            }

            assert_response :success

            assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
          end

          it 'includes the client name in the preview form' do
            post_create attrs: {
              establishment_id: establishment.id,
              billing_mode: 'fixed_price',
              time_length_approx: time_length,
              time_length: nil,
              daily_order_amount: nil
            }

            assert_response :success

            assert_select "div.text-bold", 'FTOPIA SAS'
          end
        end
      end
    end

    describe 'on the destroy_annex action' do
      describe 'when a contract is in edition' do
        before { current_contract_with_attachment }

        it 'destroy the attachment' do
          assert_difference 'Goxygene::OfficeBusinessContractsDocument.count', -1 do
            delete "/bureau_consultant/commercial_contracts/#{current_contract.id}/annexes/#{current_contract.office_business_contracts_document_ids.first}"
          end
        end

        it 'responds with success' do
          delete "/bureau_consultant/commercial_contracts/#{current_contract.id}/annexes/#{current_contract.office_business_contracts_document_ids.first}"

          assert_response :success
        end
      end
    end

    describe 'on the new commercial contract page' do
      describe 'when a contract is in edition' do
        before do
          current_contract_with_attachment

          get '/bureau_consultant/commercial_contracts/new'
        end

        it 'renders the page with existing data' do
          assert_response :success
        end

        it 'displays a delete button' do
          assert_select 'button.reset-form', "Saisir un nouveau contrat"
        end

        it 'displays attachments' do
          assert_select "div#commercial_contract_file_upload_#{current_contract.office_business_contracts_document_ids.first} label",
                        'sample1.pdf'
        end

        it 'lists the vat rates' do
          assert_select 'select#office_business_contract_vat_id option', Goxygene::Vat.active.for_bureau.count

          css_select('select#office_business_contract_vat_id option').each do |vat_value|
            assert Goxygene::Vat.active.for_bureau.find(vat_value.attributes['value'].value)
          end
        end
      end

      describe 'when no contract is in edition' do
        before do
          consultant.office_business_contracts.in_edition.destroy_all
          get '/bureau_consultant/commercial_contracts/new'
        end

        it 'renders the page with a new contract' do
          assert_response :success
        end

        it 'does not includes duplicates in the client list' do
          count = consultant.establishments_from_contacts.uniq.count

          assert_select "select#office_business_contract_establishment_id option", count + 1
        end

        it 'set the establishment country from the consultant' do
          country = consultant.contact_datum.country

          assert_select "select#office_business_contract_establishment_country_id option[value=\"#{country.id}\"][selected]"
        end

        it 'set the contact country from the consultant' do
          country = consultant.contact_datum.country

          assert_select "select#office_business_contract_contact_country_id option[value=\"#{country.id}\"][selected]"
        end

        it 'displays the "Délai de résiliation" field' do
          assert_select 'label[for="office_business_contract_notice_period"]', 'Délai de résilliation (en semaine)'
          assert_select 'input#office_business_contract_notice_period'
        end

        it 'displays the time_length field only once' do
          assert_select 'input#time-length-input', 1
          assert_select 'input#office_business_contract_time_length', 0
        end

        it 'displays the "Raison sociale" field' do
          assert_select 'label[for="office_business_contract_establishment_name"]', 'Raison sociale'
          assert_select 'input#office_business_contract_establishment_name'
        end

        it 'displays the "Frais pris en charge par le client" field' do
          assert_select 'label[for="office_business_contract_expenses_comment"]', 'Frais pris en charge par le client'
          assert_select 'input#office_business_contract_expenses_comment'
        end

        it 'displays the "Dispositions particulières pour le remboursement de frais" field' do
          assert_select 'label[for="office_business_contract_expenses_payback_comment"]', 'Dispositions particulières pour le remboursement de frais'
          assert_select 'input#office_business_contract_expenses_payback_comment'
        end

        it 'displays the "Remarques pour le traitement du contrat" field' do
          assert_select 'label[for="office_business_contract_contract_handling_comment"]', 'Remarques pour le traitement du contrat'
          assert_select 'input#office_business_contract_contract_handling_comment'
        end

        it 'displays the "Modalités de facturation et de paiement / informations complémentaires" field' do
          assert_select 'label[for="office_business_contract_payment_comment"]', 'Modalités de facturation et de paiement / informations complémentaires'
          assert_select 'input#office_business_contract_payment_comment'
        end

        it 'displays the right label for billing mode' do
          assert_select 'select#billing_mode_select option[value="fixed_price"]', 'Montant Forfaitaire'
          assert_select 'select#billing_mode_select option[value="time_basis"]', 'Montant Journalier'
        end

        it 'displays only the showonbureau list for contact_type' do
          assert Goxygene::ContactType.for_bureau.count > 0
          assert_select 'select#office_business_contract_contact_contact_type_id option', Goxygene::ContactType.for_bureau.count
        end
      end
    end

    describe 'on the new_from_siret commercial contract page' do
      ['72130541762587', '721 305 417 62587', "\t721 305 417 62587"].each do |siret|
        let(:establishment_from_siret) { Goxygene::Establishment.find_by siret: siret.delete("^0-9") }
        let(:last_created_contact) { Goxygene::EstablishmentContact.last }

        describe 'when a contract is in edition' do
          before do
            current_contract_with_attachment
          end

          it 'does not create a new establishment' do
            assert_no_difference 'Goxygene::Establishment.count' do
              get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }
            end
          end

          it 'creates a new establishment contact linked to the consultant' do
            assert_difference 'Goxygene::EstablishmentContact.count' do
              get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }
            end

            assert_equal consultant, Goxygene::EstablishmentContact.last.consultant
          end

          it 'renders the page with existing data' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_response :success
          end

          it 'lists the vat rates' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select 'select#office_business_contract_vat_id option', Goxygene::Vat.active.for_bureau.count

            css_select('select#office_business_contract_vat_id option').each do |vat_value|
              assert Goxygene::Vat.active.for_bureau.find(vat_value.attributes['value'].value)
            end
          end
        end

        describe 'when no contract is in edition' do
          before do
            consultant.office_business_contracts.in_edition.destroy_all
          end

          it 'does not create a new establishment' do
            assert_no_difference 'Goxygene::Establishment.count' do
              get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }
            end
          end

          it 'creates a new establishment contact linked to the consultant' do
            assert_difference 'Goxygene::EstablishmentContact.count' do
              get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }
            end

            assert_equal consultant, Goxygene::EstablishmentContact.last.consultant
          end

          it 'renders the page with a new contract' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_response :success
          end

          it 'does not includes duplicates in the client list' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            count = consultant.establishments_from_contacts.uniq.count

            assert_select "select#office_business_contract_establishment_id option", count + 1
          end

          it 'set the establishment siret from the establishment' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select "input#office_business_contract_establishment_siret[value=\"#{siret.delete("^0-9")}\"]"
          end

          it 'set the establishment name from the establishment' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select "input#office_business_contract_establishment_name[value=\"#{establishment_from_siret.name}\"]"
          end

          it 'set the establishment zipcode from the establishment' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select "input#office_business_contract_establishment_zip_code[value=\"#{establishment_from_siret.contact_datum.zip_code}\"]"
          end

          it 'set the establishment city from the establishment' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select "input#office_business_contract_establishment_city[value=\"#{establishment_from_siret.contact_datum.city}\"]"
          end

          it 'set the establishment country from the establishment' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            country = establishment_from_siret.contact_datum.country

            assert_select "select#office_business_contract_establishment_country_id option[value=\"#{country.id}\"][selected]"
          end

          it 'sets the contact_id' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select "select#office_business_contract_establishment_contact_id option[value=\"#{last_created_contact.id}\"][selected]"
          end

          it 'set the contact lastname from the establishment name' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select "input#office_business_contract_contact_last_name[value=\"#{establishment_from_siret.name}\"]"
          end

          it 'set the contact country from the establishment' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            country = establishment_from_siret.contact_datum.country

            assert_select "select#office_business_contract_contact_country_id option[value=\"#{country.id}\"][selected]"
          end

          it 'set the contact zipcode from the establishment' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select "input#office_business_contract_contact_zip_code_id[value=\"#{establishment_from_siret.contact_datum.zip_code_id}\"]"
          end

          it 'set the contact city from the establishment' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select "input#office_business_contract_contact_city[value=\"#{establishment_from_siret.contact_datum.city}\"]"
          end

          it 'displays the "Délai de résiliation" field' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_notice_period"]', 'Délai de résilliation (en semaine)'
            assert_select 'input#office_business_contract_notice_period'
          end

          it 'displays the time_length field only once' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select 'input#time-length-input', 1
            assert_select 'input#office_business_contract_time_length', 0
          end

          it 'displays the "Raison sociale" field' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_establishment_name"]', 'Raison sociale'
            assert_select 'input#office_business_contract_establishment_name'
          end

          it 'displays the "Frais pris en charge par le client" field' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_expenses_comment"]', 'Frais pris en charge par le client'
            assert_select 'input#office_business_contract_expenses_comment'
          end

          it 'displays the "Dispositions particulières pour le remboursement de frais" field' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_expenses_payback_comment"]', 'Dispositions particulières pour le remboursement de frais'
            assert_select 'input#office_business_contract_expenses_payback_comment'
          end

          it 'displays the "Remarques pour le traitement du contrat" field' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_contract_handling_comment"]', 'Remarques pour le traitement du contrat'
            assert_select 'input#office_business_contract_contract_handling_comment'
          end

          it 'displays the "Modalités de facturation et de paiement / informations complémentaires" field' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_payment_comment"]', 'Modalités de facturation et de paiement / informations complémentaires'
            assert_select 'input#office_business_contract_payment_comment'
          end

          it 'displays the right label for billing mode' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert_select 'select#billing_mode_select option[value="fixed_price"]', 'Montant Forfaitaire'
            assert_select 'select#billing_mode_select option[value="time_basis"]', 'Montant Journalier'
          end

          it 'displays only the showonbureau list for contact_type' do
            get '/bureau_consultant/commercial_contracts/new_from_siret', params: { siret: siret }

            assert Goxygene::ContactType.for_bureau.count > 0
            assert_select 'select#office_business_contract_contact_contact_type_id option', Goxygene::ContactType.for_bureau.count
          end
        end
      end
    end

    describe 'on the contract request history page' do

      let(:default_filter_date_lower_bound)  { Date.today.last_year.beginning_of_year }
      let(:default_filter_date_higher_bound) { Date.current.end_of_year + 6.months    }
      let(:filter_date_lower_bound)          { 2.year.ago.beginning_of_year.to_date   }
      let(:filter_date_higher_bound)         { 6.months.ago.to_date                   }

      it 'displays the contract requests history page' do
        get '/bureau_consultant/commercial_contracts/contract_request'
        assert_response :success
      end

      it 'displays the client name' do
        get '/bureau_consultant/commercial_contracts/contract_request'

        assert_select "th", "Client"
        assert_select "td", "FTOPIA SAS"
      end

      it 'displays the request status' do
        get '/bureau_consultant/commercial_contracts/contract_request'

        assert_select 'td', 'En traitement'
      end

      it 'includes a checkbox for xls export' do
        get '/bureau_consultant/commercial_contracts/contract_request'

        assert_select 'input[type="checkbox"][name="q[id_in][]"]'
      end

      it 'displays contracts within the default date range' do
        get '/bureau_consultant/commercial_contracts/contract_request'

        # check for the filter form values
        assert_ransack_filter :begining_date_gteq, default_filter_date_lower_bound.strftime('%d/%m/%Y')
        assert_ransack_filter :begining_date_lteq, default_filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.commercial_contract").each do |entry|
          entry_date = Date.parse(entry.css("td.commercial_contract_begining_date").first.content)
          assert entry_date >= default_filter_date_lower_bound
          assert entry_date <= default_filter_date_higher_bound
        end
      end

      it 'can filter by beginning date' do
        get '/bureau_consultant/commercial_contracts/contract_request',
            params: {
              q: {
                begining_date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                begining_date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y'),
              }
            }

        # check for the filter form values
        assert_ransack_filter :begining_date_gteq, filter_date_lower_bound.strftime('%d/%m/%Y')
        assert_ransack_filter :begining_date_lteq, filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.statement_of_activities_request").each do |entry|
          entry_date = Date.parse(entry.css("td.commercial_contract_begining_date").first.content)
          assert entry_date >= filter_date_lower_bound
          assert entry_date <= filter_date_higher_bound
        end
      end
    end

    describe 'on the contract signed history page' do

      let(:default_filter_date_lower_bound)  { Date.today.last_year.beginning_of_year }
      let(:default_filter_date_higher_bound) { Date.current.end_of_year + 6.months    }
      let(:filter_date_lower_bound)          { 5.year.ago.beginning_of_year.to_date   }
      let(:filter_date_higher_bound)         { 6.months.ago.to_date                   }

      it 'displays the contracts signed history page' do
        get '/bureau_consultant/commercial_contracts/contract_signed'

        assert_response :success
      end

      it 'lists only the contract_of_operation type' do
        get '/bureau_consultant/commercial_contracts/contract_signed'

        assert_select 'tr.commercial_contract', 2
      end

      it 'includes a checkbox for xls export' do
        get '/bureau_consultant/commercial_contracts/contract_signed'

        assert_select 'input[type="checkbox"][name="q[id_in][]"]'
      end

      it 'displays contracts within the default date range' do
        get '/bureau_consultant/commercial_contracts/contract_signed'

        # check for the filter form values
        assert_ransack_filter :begining_date_gteq, default_filter_date_lower_bound.strftime('%d/%m/%Y')
        assert_ransack_filter :begining_date_lteq, default_filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.commercial_contract").each do |entry|
          entry_date = Date.parse(entry.css("td.commercial_contract_begining_date").first.content)
          assert entry_date >= default_filter_date_lower_bound
          assert entry_date <= default_filter_date_higher_bound
        end
      end

      it 'can filter by beginning date' do
        get '/bureau_consultant/commercial_contracts/contract_signed',
            params: {
              q: {
                begining_date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                begining_date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y'),
              }
            }

        # check for the filter form values
        assert_ransack_filter :begining_date_gteq, filter_date_lower_bound.strftime('%d/%m/%Y')
        assert_ransack_filter :begining_date_lteq, filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.statement_of_activities_request").each do |entry|
          entry_date = Date.parse(entry.css("td.commercial_contract_begining_date").first.content)
          assert entry_date >= filter_date_lower_bound
          assert entry_date <= filter_date_higher_bound
        end
      end
    end

    describe 'on the export_contract_request action' do
      let(:workbook) { RubyXL::Parser.parse_buffer(response.body) }
    describe "on the contract signed show page" do
      let(:business_contract_signed_doc1) do
        consultant.individual.tier.documents.create!(
          filename: fixture_file_upload("files/sample1.pdf", "application/pdf"),
          document_type: Goxygene::DocumentType.prospect_business_contract_documents.first,
          document_format: Goxygene::DocumentFormat.find_by(file_extension: "PDF"),
          created_by: cas_authentications(:jackie_denesik).cas_user.id,
          updated_by: cas_authentications(:jackie_denesik).cas_user.id
        )
      end

      let(:business_contract_signed_doc2) do
        consultant.individual.tier.documents.create!(
          filename: fixture_file_upload("files/sample2.pdf", "application/pdf"),
          document_type: Goxygene::DocumentType.prospect_business_contract_documents.first,
          document_format: Goxygene::DocumentFormat.find_by(file_extension: "PDF"),
          created_by: cas_authentications(:jackie_denesik).cas_user.id,
          updated_by: cas_authentications(:jackie_denesik).cas_user.id
        )
      end

      let(:latest_contract) do
        contract = consultant.business_contracts.last
        contract.documents << [business_contract_signed_doc1, business_contract_signed_doc2]
        contract.save!
        contract.business_contract_documents.each {|bsd| bsd.update(business_contract_version_id: consultant.business_contracts.last.last_version_by_id.id) }

        contract
      end

      it "displays the contract signed show page" do
        get "/bureau_consultant/commercial_contracts/contract_signed/#{latest_contract.id}"
          assert_response :success
      end
    end

      before do
        get "/bureau_consultant/commercial_contracts/contract_request/export.xlsx",
            params: {
              q: {
                id_in: consultant.office_business_contract_ids,
                begining_date_gteq: 10.years.ago.strftime('%d/%m/%Y'),
                ending_date_lteq: 10.years.from_now.strftime('%d/%m/%Y')
              }
            }
      end

      it 'responds with success' do
        assert_response :success
      end

      it 'translates the status' do
        assert_equal 'En traitement', workbook[0][1][1].value
      end

      it 'does not format the amount' do
        assert workbook[0][1][4].value.is_a? Float
      end
    end

    describe 'on the export_contract_signed action' do
      let(:workbook) { RubyXL::Parser.parse_buffer(response.body) }

      before do
        get "/bureau_consultant/commercial_contracts/contract_signed/export.xlsx",
            params: {
              q: {
                id_in: consultant.business_contract_ids,
                begining_date_gteq: 10.years.ago.strftime('%d/%m/%Y'),
                ending_date_lteq: 10.years.from_now.strftime('%d/%m/%Y')
              }
            }
      end

      it 'responds with success' do
        assert_response :success
      end

      it 'does not format the amount without taxes' do
        assert workbook[0][1][5].value.is_a?(Float)
      end

      it 'does not format the amount with taxes' do
        assert workbook[0][1][6].value.is_a?(Float)
      end
    end
  end

  describe 'not authenticated' do
    describe 'on the contracts siggned history page' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/commercial_contracts/contract_signed'
        assert_redirected_to '/cas_authentications/sign_in'
      end

      it 'redirects to the authentication page' do
        get '/bureau_consultant/commercial_contracts/contract_request'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end
  end
end

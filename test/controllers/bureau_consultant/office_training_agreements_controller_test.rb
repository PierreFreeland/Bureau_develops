require 'test_helper'

describe BureauConsultant::OfficeTrainingAgreementsController do
  describe 'authenticated as a consultant' do

    let(:consultant)               { Goxygene::Consultant.find 9392    }
    let(:establishment)            { consultant.establishments_from_contacts.first   }
    let(:establishment_name)       { FFaker::Name.name                 }
    let(:first_name)               { FFaker::Name.first_name           }
    let(:last_name)                { FFaker::Name.last_name.upcase     }
    let(:beginning_date)           { Date.current + 2.days             }
    let(:ending_date)              { beginning_date + 5.days           }
    let(:order_amount)             { rand(5000) + 200                  }
    let(:daily_order_amount)       { rand(5000) + 250                  }
    let(:advance_payment)          { rand(123) + 100                   }
    let(:establishment_name)       { FFaker::Name.name                 }
    let(:consultant_comment)       { FFaker::Lorem.words(5).join(' ')  }
    let(:expenses_comment)         { FFaker::Lorem.words(5).join(' ')  }
    let(:expenses_payback_comment) { FFaker::Lorem.words(5).join(' ')  }
    let(:contract_handling_comment){ FFaker::Lorem.words(5).join(' ')  }
    let(:vat_id)                   { 12                                }
    let(:time_length)              { 2                                 }
    let(:time_hours_length)        { 1                                 }
    let(:mission_subject)            { FFaker::Lorem.words(5).join(' ')  }
    let(:training_purpose)         { FFaker::Lorem.words(5).join(' ')  }
    let(:training_location)        { FFaker::Lorem.words(5).join(' ')  }
    let(:training_location_booking){ FFaker::Lorem.words(5).join(' ')  }
    let(:trainees)                 { rand(5)                           }
    let(:notice_period) { rand(5)                           }


    let(:new_siret)                { '73282932000074'               }
    let(:new_name)                 { FFaker::Name.name              }
    let(:new_address)              { FFaker::Address.street_address }
    let(:new_zip_code)             { "12345"                        }
    let(:new_city)                 { FFaker::Address.city           }

    let(:contact_type)             { Goxygene::ContactType.all.shuffle.first }
    let(:contact_role)             { Goxygene::ContactRole.all.shuffle.first }

    let(:training_target)          { Goxygene::TrainingTarget.active.all.shuffle.last }
    let(:training_domain)          { Goxygene::TrainingDomain.active.all.shuffle.last }

    let(:contract_expense_label)    { FFaker::Lorem.words(5).join(' ')  }
    let(:contract_expense_cost)     { rand(12345)                       }
    let(:contract_expense_number)   { rand(123)                         }
    let(:contract_expense_trainees) { rand(12)                          }
    let(:contract_expense_total_cost) { rand(10)                             }
    let(:contract_expenses) do
      {
        rand(99999999) => {
          label:    contract_expense_label,
          cost:     contract_expense_cost,
          number:   contract_expense_number,
          trainees: contract_expense_trainees,
          total_cost: contract_expense_total_cost,
          _destroy: false
        }
      }
    end

    let(:training_agreement_attrs) do
      {
        training_purpose:         training_purpose,
        training_location:        training_location,
        training_location_booking:training_location_booking,
        trainees:                 trainees,
        training_target_id:       training_target.id,
        training_domain_id:       training_domain.id,
      }
    end

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

        begining_date:            beginning_date,
        ending_date:              ending_date,
        time_length:              time_length,
        time_hours_length:        time_hours_length,
        daily_order_amount:       daily_order_amount,
        order_amount:             order_amount,
        vat_id:                   vat_id,
        advance_payment:          advance_payment,
        notice_period:            notice_period,
        mission_subject:            mission_subject,

        consultant_comment:         consultant_comment,
        expenses_comment:           expenses_comment,
        expenses_payback_comment:   expenses_payback_comment,
        contract_handling_comment:  contract_handling_comment,

        office_business_contract_expenses_attributes: contract_expenses,
        office_training_agreement_attributes: training_agreement_attrs,

        consultant_itg_establishment_id: consultant.itg_establishment_id
      }
    end

    let(:current_contract) do
      contract = consultant.office_training_agreements.build
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

    let(:office_business_contract) { consultant.office_training_agreements.last }

    before { sign_in cas_authentications(:jackie_denesik) }

    def post_create(attrs: {}, attachments: [])
      type_id = Goxygene::DocumentType.cf_document.first.id

      post '/bureau_consultant/office_training_agreements', params: {
        office_business_contract: contract_attributes.merge(attrs),
        attachments: attachments,
        attachment_types: attachments.map { |_| type_id }
      }
    end

    describe 'on a mobile device' do
      describe 'on the new page' do
        describe 'when a contract is in edition' do
          before do
            skip
            current_contract_with_attachment

            get '/m/bureau_consultant/office_training_agreements/new'
          end

          it 'renders the page with existing data' do
            assert_response :success
          end

          it 'displays a delete button' do
            assert_select 'button#reset-form', "Saisir un nouveau contrat"
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
            get '/m/bureau_consultant/office_training_agreements/new'
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
            assert_select 'label[for="office_business_contract_notice_period"]', 'Dédit'
            assert_select 'input#office_business_contract_notice_period'
          end

          it 'displays the time_length field only once' do
            assert_select 'input#time-length-input', 1
            assert_select 'input#office_business_contract_time_length', 0
          end

          it 'displays the right label for the time_length field' do
            assert_select 'label[for="office_business_contract_time_length"]', 'Durée (en jours)'
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

          it 'displays the "Lieux" field' do
            assert_select 'label[for="office_business_contract_office_training_agreement_attributes_training_location"]', 'Lieux'
            assert_select 'input#office_business_contract_office_training_agreement_attributes_training_location'
          end

          it 'the "Lieux" field must accepts alphanum chars' do
            css_select('input#office_business_contract_office_training_agreement_attributes_training_location').each do |element|
              assert element.attributes['class'].value.match(/number-field/).nil?
            end
          end

          it 'displays the "La(les) salle(s) sera(ont) retenue(s) par" field' do
            assert_select 'label[for="office_business_contract_office_training_agreement_attributes_training_location_booking"]', 'La(les) salle(s) sera(ont) retenue(s) par'
            assert_select 'input#office_business_contract_office_training_agreement_attributes_training_location_booking'
          end

          it 'the "La(les) salle(s) sera(ont) retenue(s) par" field must accepts alphanum chars' do
            css_select('input#office_business_contract_office_training_agreement_attributes_training_location_booking').each do |element|
              assert element.attributes['class'].value.match(/number-field/).nil?
            end
          end

          it 'displays the "Effectif formé (personnes)" field' do
            assert_select 'label[for="office_business_contract_office_training_agreement_attributes_trainees"]', 'Effectif formé (personnes)'
            assert_select 'input#office_business_contract_office_training_agreement_attributes_trainees'
          end

          it 'the "Effectif formé (personnes)" field must accepts alphanum chars' do
            css_select('input#office_business_contract_trainees').each do |element|
              assert element.attributes['class'].value.match(/number-field/).nil?
            end
          end

          it 'displays the right label for billing mode' do
            assert_select 'select#billing_mode_select option[value="fixed_price"]', 'Montant Forfaitaire'
            assert_select 'select#billing_mode_select option[value="time_basis"]', 'Montant Journalier'
          end

          it 'displays the "Intitulé du stage" field' do
            assert_select 'label[for="office_business_contract_mission_subject"]', 'Intitulé du stage'
            assert_select 'input#office_business_contract_mission_subject'
          end

          it 'the "Intitulé du stage" field must accepts alphanum chars' do
            css_select('input#office_business_contract_mission_subject').each do |element|
              assert element.attributes['class'].value.match(/number-field/).nil?
            end
          end

          it 'displays the "Objectifs du stage" field' do
            assert_select 'label[for="office_business_contract_office_training_agreement_attributes_training_purpose"]', 'Objectifs du stage'
            assert_select 'input#office_business_contract_office_training_agreement_attributes_training_purpose'
          end

          it 'the "Objectifs du stage" field must accepts alphanum chars' do
            css_select('input#office_business_contract_office_training_agreement_attributes_training_purpose').each do |element|
              assert element.attributes['class'].value.match(/number-field/).nil?
            end
          end

          it 'displays the "Type d’action de formation" field' do
            assert_select 'label[for="office_business_contract_office_training_agreement_attributes_training_target_id"]', 'Type d’action de formation'
            assert_select 'select#office_business_contract_office_training_agreement_attributes_training_target_id'
          end

          it 'displays only the showonbureau list for contact_type' do
            assert Goxygene::ContactType.for_bureau.count > 0
            assert_select 'select#office_business_contract_contact_contact_type_id option', Goxygene::ContactType.for_bureau.count
          end
        end
      end

      describe 'on the requests history page' do

        let(:default_filter_date_lower_bound)  { Date.today.last_year.beginning_of_year }
        let(:default_filter_date_higher_bound) { Date.current.end_of_year + 6.months    }
        let(:filter_date_lower_bound)          { 2.year.ago.beginning_of_year.to_date   }
        let(:filter_date_higher_bound)         { 6.months.ago.to_date                   }

        it 'displays the contract requests history page' do
          get '/m/bureau_consultant/office_training_agreements/requests'
          assert_response :success
        end

        it 'displays contracts within the default date range' do
          get '/m/bureau_consultant/office_training_agreements/requests'

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
          get '/m/bureau_consultant/office_training_agreements/requests',
              params: {
                q: {
                  begining_date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                  begining_date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y'),
                }
              }

          # check for the filter form values
          assert_ransack_filter :begining_date_gteq, filter_date_lower_bound .strftime('%d/%m/%Y')
          assert_ransack_filter :begining_date_lteq, filter_date_higher_bound.strftime('%d/%m/%Y')

          # check if each entry is within the date range
          css_select("tr.statement_of_activities_request").each do |entry|
            entry_date = Date.parse(entry.css("td.commercial_contract_begining_date").first.content)
            assert entry_date >= filter_date_lower_bound
            assert entry_date <= filter_date_higher_bound
          end
        end
      end

      describe 'on the signed history page' do

        let(:default_filter_date_lower_bound)  { Date.today.last_year.beginning_of_year }
        let(:default_filter_date_higher_bound) { Date.current.end_of_year + 6.months    }
        let(:filter_date_lower_bound)          { 5.year.ago.beginning_of_year.to_date   }
        let(:filter_date_higher_bound)         { 6.months.ago.to_date                   }

        it 'displays the contracts signed history page' do
          get '/m/bureau_consultant/office_training_agreements/signed'

          assert_response :success
        end

        it 'displays contracts within the default date range' do
          get '/m/bureau_consultant/office_training_agreements/signed'

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
          get '/m/bureau_consultant/office_training_agreements/signed',
              params: {
                q: {
                  begining_date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                  begining_date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y'),
                }
              }

          # check for the filter form values
          assert_ransack_filter :begining_date_gteq, filter_date_lower_bound .strftime('%d/%m/%Y')
          assert_ransack_filter :begining_date_lteq, filter_date_higher_bound.strftime('%d/%m/%Y')

          # check if each entry is within the date range
          css_select("tr.statement_of_activities_request").each do |entry|
            entry_date = Date.parse(entry.css("td.commercial_contract_begining_date").first.content)
            assert entry_date >= filter_date_lower_bound
            assert entry_date <= filter_date_higher_bound
          end
        end
      end
    end

    describe 'on the new page' do
      describe 'when a contract is in edition' do
        before do
          skip
          current_contract_with_attachment

          get '/bureau_consultant/office_training_agreements/new'
        end

        it 'renders the page with existing data' do
          assert_response :success
        end

        it 'displays a delete button' do
          assert_select 'button#reset-form', "Saisir un nouveau contrat"
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
          get '/bureau_consultant/office_training_agreements/new'
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
          assert_select 'label[for="office_business_contract_notice_period"]', 'Dédit'
          assert_select 'input#office_business_contract_notice_period'
        end

        it 'displays the time_length field only once' do
          assert_select 'input#time-length-input', 1
          assert_select 'input#office_business_contract_time_length', 0
        end

        it 'displays the right label for the time_length field' do
          assert_select 'label[for="office_business_contract_time_length"]', 'Durée (en jours)'
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

        it 'displays the "Lieux" field' do
          assert_select 'label[for="office_business_contract_office_training_agreement_attributes_training_location"]', 'Lieux'
          assert_select 'input#office_business_contract_office_training_agreement_attributes_training_location'
        end

        it 'the "Lieux" field must accepts alphanum chars' do
          css_select('input#office_business_contract_office_training_agreement_attributes_training_location').each do |element|
            assert element.attributes['class'].value.match(/number-field/).nil?
          end
        end

        it 'displays the "La(les) salle(s) sera(ont) retenue(s) par" field' do
          assert_select 'label[for="office_business_contract_office_training_agreement_attributes_training_location_booking"]', 'La(les) salle(s) sera(ont) retenue(s) par'
          assert_select 'input#office_business_contract_office_training_agreement_attributes_training_location_booking'
        end

        it 'the "La(les) salle(s) sera(ont) retenue(s) par" field must accepts alphanum chars' do
          css_select('input#office_business_contract_office_training_agreement_attributes_training_location_booking').each do |element|
            assert element.attributes['class'].value.match(/number-field/).nil?
          end
        end

        it 'displays the "Effectif formé (personnes)" field' do
          assert_select 'label[for="office_business_contract_office_training_agreement_attributes_trainees"]', 'Effectif formé (personnes)'
          assert_select 'input#office_business_contract_office_training_agreement_attributes_trainees'
        end

        it 'the "Effectif formé (personnes)" field must accepts alphanum chars' do
          css_select('input#office_business_contract_office_training_agreement_attributes_trainees').each do |element|
            assert element.attributes['class'].value.match(/number-field/).nil?
          end
        end

        it 'displays the right label for billing mode' do
          assert_select 'select#billing_mode_select option[value="fixed_price"]', 'Montant Forfaitaire'
          assert_select 'select#billing_mode_select option[value="time_basis"]', 'Montant Journalier'
        end

        it 'displays the "Intitulé du stage" field' do
          assert_select 'label[for="office_business_contract_mission_subject"]', 'Intitulé du stage'
          assert_select 'input#office_business_contract_mission_subject'
        end

        it 'the "Intitulé du stage" field must accepts alphanum chars' do
          css_select('input#office_business_contract_mission_subject').each do |element|
            assert element.attributes['class'].value.match(/number-field/).nil?
          end
        end

        it 'displays the "Objectifs du stage" field' do
          assert_select 'label[for="office_business_contract_office_training_agreement_attributes_training_purpose"]', 'Objectifs du stage'
          assert_select 'input#office_business_contract_office_training_agreement_attributes_training_purpose'
        end

        it 'the "Objectifs du stage" field must accepts alphanum chars' do
          css_select('input#office_business_contract_office_training_agreement_attributes_training_purpose').each do |element|
            assert element.attributes['class'].value.match(/number-field/).nil?
          end
        end

        it 'displays the "Type d’action de formation" field' do
          assert_select 'label[for="office_business_contract_office_training_agreement_attributes_training_target_id"]', 'Type d’action de formation'
          assert_select 'select#office_business_contract_office_training_agreement_attributes_training_target_id'
        end

        it 'displays only the showonbureau list for contact_type' do
          assert Goxygene::ContactType.for_bureau.count > 0
          assert_select 'select#office_business_contract_contact_contact_type_id option', Goxygene::ContactType.for_bureau.count
        end
      end
    end

    describe 'on the new_from_siret page' do
      [ '72130541762587', '721 305 417 62587', "\t721 305 417 62587" ].each do |siret|
        let(:establishment_from_siret) { Goxygene::Establishment.find_by siret: siret.delete("^0-9") }
        let(:last_created_contact) { Goxygene::EstablishmentContact.last }

        describe 'when a contract is in edition' do
          before do
            skip
            current_contract_with_attachment
          end

          it 'does not create a new establishment' do
            assert_no_difference 'Goxygene::Establishment.count' do
              get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }
            end
          end

          it 'creates a new establishment contact linked to the consultant' do
            assert_difference 'Goxygene::EstablishmentContact.count' do
              get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }
            end

            assert_equal consultant, Goxygene::EstablishmentContact.last.consultant
          end

          it 'renders the page with existing data' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_response :success
          end

          it 'displays a delete button' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select 'button#reset-form', "Saisir un nouveau contrat"
          end

          it 'displays attachments' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select "div#commercial_contract_file_upload_#{current_contract.office_business_contracts_document_ids.first} label",
                          'sample1.pdf'
          end

          it 'lists the vat rates' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

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
              get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }
            end
          end

          it 'creates a new establishment contact linked to the consultant' do
            assert_difference 'Goxygene::EstablishmentContact.count' do
              get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }
            end

            assert_equal consultant, Goxygene::EstablishmentContact.last.consultant
          end

          it 'renders the page with a new contract' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_response :success
          end

          it 'does not includes duplicates in the client list' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            count = consultant.establishments_from_contacts.uniq.count

            assert_select "select#office_business_contract_establishment_id option", count + 1
          end

          it 'set the establishment siret from the establishment' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select "input#office_business_contract_establishment_siret[value=\"#{siret.delete("^0-9")}\"]"
          end

          it 'set the establishment name from the establishment' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select "input#office_business_contract_establishment_name[value=\"#{establishment_from_siret.name}\"]"
          end

          it 'set the establishment zipcode from the establishment' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select "input#office_business_contract_establishment_zip_code[value=\"#{establishment_from_siret.contact_datum.zip_code}\"]"
          end

          it 'set the establishment city from the establishment' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select "input#office_business_contract_establishment_city[value=\"#{establishment_from_siret.contact_datum.city}\"]"
          end

          it 'set the establishment country from the establishment' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            country = establishment_from_siret.contact_datum.country

            assert_select "select#office_business_contract_establishment_country_id option[value=\"#{country.id}\"][selected]"
          end

          it 'sets the contact_id' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select "select#office_business_contract_establishment_contact_id option[value=\"#{last_created_contact.id}\"][selected]"
          end

          it 'set the contact lastname from the establishment name' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select "input#office_business_contract_contact_last_name[value=\"#{establishment_from_siret.name}\"]"
          end

          it 'set the contact country from the establishment' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            country = establishment_from_siret.contact_datum.country

            assert_select "select#office_business_contract_contact_country_id option[value=\"#{country.id}\"][selected]"
          end

          it 'set the contact zipcode from the establishment' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select "input#office_business_contract_contact_zip_code_id[value=\"#{establishment_from_siret.contact_datum.zip_code_id}\"]"
          end

          it 'set the contact city from the establishment' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select "input#office_business_contract_contact_city[value=\"#{establishment_from_siret.contact_datum.city}\"]"
          end

          it 'displays the "Délai de résiliation" field' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_notice_period"]', 'Dédit'
            assert_select 'input#office_business_contract_notice_period'
          end

          it 'displays the time_length field only once' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select 'input#time-length-input', 1
            assert_select 'input#office_business_contract_time_length', 0
          end

          it 'displays the right label for the time_length field' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_time_length"]', 'Durée (en jours)'
          end

          it 'displays the "Raison sociale" field' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_establishment_name"]', 'Raison sociale'
            assert_select 'input#office_business_contract_establishment_name'
          end

          it 'displays the "Frais pris en charge par le client" field' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_expenses_comment"]', 'Frais pris en charge par le client'
            assert_select 'input#office_business_contract_expenses_comment'
          end

          it 'displays the "Dispositions particulières pour le remboursement de frais" field' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_expenses_payback_comment"]', 'Dispositions particulières pour le remboursement de frais'
            assert_select 'input#office_business_contract_expenses_payback_comment'
          end

          it 'displays the "Remarques pour le traitement du contrat" field' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_contract_handling_comment"]', 'Remarques pour le traitement du contrat'
            assert_select 'input#office_business_contract_contract_handling_comment'
          end

          it 'displays the "Modalités de facturation et de paiement / informations complémentaires" field' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_payment_comment"]', 'Modalités de facturation et de paiement / informations complémentaires'
            assert_select 'input#office_business_contract_payment_comment'
          end

          it 'displays the "Lieux" field' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_office_training_agreement_attributes_training_location"]', 'Lieux'
            assert_select 'input#office_business_contract_office_training_agreement_attributes_training_location'
          end

          it 'the "Lieux" field must accepts alphanum chars' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            css_select('input#office_business_contract_office_training_agreement_attributes_training_location').each do |element|
              assert element.attributes['class'].value.match(/number-field/).nil?
            end
          end

          it 'displays the "La(les) salle(s) sera(ont) retenue(s) par" field' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_office_training_agreement_attributes_training_location_booking"]', 'La(les) salle(s) sera(ont) retenue(s) par'
            assert_select 'input#office_business_contract_office_training_agreement_attributes_training_location_booking'
          end

          it 'the "La(les) salle(s) sera(ont) retenue(s) par" field must accepts alphanum chars' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            css_select('input#office_business_contract_office_training_agreement_attributes_training_location_booking').each do |element|
              assert element.attributes['class'].value.match(/number-field/).nil?
            end
          end

          it 'displays the "Effectif formé (personnes)" field' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_office_training_agreement_attributes_trainees"]', 'Effectif formé (personnes)'
            assert_select 'input#office_business_contract_office_training_agreement_attributes_trainees'
          end

          it 'the "Effectif formé (personnes)" field must accepts alphanum chars' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            css_select('input#office_business_contract_office_training_agreement_attributes_trainees').each do |element|
              assert element.attributes['class'].value.match(/number-field/).nil?
            end
          end

          it 'displays the right label for billing mode' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select 'select#billing_mode_select option[value="fixed_price"]', 'Montant Forfaitaire'
            assert_select 'select#billing_mode_select option[value="time_basis"]', 'Montant Journalier'
          end

          it 'displays the "Intitulé du stage" field' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_mission_subject"]', 'Intitulé du stage'
            assert_select 'input#office_business_contract_mission_subject'
          end

          it 'the "Intitulé du stage" field must accepts alphanum chars' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            css_select('input#office_business_contract_mission_subject').each do |element|
              assert element.attributes['class'].value.match(/number-field/).nil?
            end
          end

          it 'displays the "Objectifs du stage" field' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_office_training_agreement_attributes_training_purpose"]', 'Objectifs du stage'
            assert_select 'input#office_business_contract_office_training_agreement_attributes_training_purpose'
          end

          it 'the "Objectifs du stage" field must accepts alphanum chars' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            css_select('input#office_business_contract_office_training_agreement_attributes_training_purpose').each do |element|
              assert element.attributes['class'].value.match(/number-field/).nil?
            end
          end

          it 'displays the "Type d’action de formation" field' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert_select 'label[for="office_business_contract_office_training_agreement_attributes_training_target_id"]', 'Type d’action de formation'
            assert_select 'select#office_business_contract_office_training_agreement_attributes_training_target_id'
          end

          it 'displays only the showonbureau list for contact_type' do
            get '/bureau_consultant/office_training_agreements/new_from_siret', params: { siret: siret }

            assert Goxygene::ContactType.for_bureau.count > 0
            assert_select 'select#office_business_contract_contact_contact_type_id option', Goxygene::ContactType.for_bureau.count
          end
        end
      end

    end

    describe 'on the create action' do
      def post_create(attrs: {}, attachments: [])
        type_id = Goxygene::DocumentType.cf_document.first.id

        post '/bureau_consultant/office_training_agreements', params: {
          office_business_contract: contract_attributes.merge(attrs),
          attachments: attachments,
          attachment_types: attachments.map { |_| type_id }
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

      describe 'when the establishment country is empty' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: { establishment_country_id: nil }
          end
        end

        it 'render the error' do
          post_create attrs: { establishment_country_id: nil }

          assert_select "form#new_office_business_contract"
        end

        it 'does not duplicate the error message' do
          post_create attrs: { establishment_country_id: nil }

          error_messages = css_select('div#error_explanation ul li').collect(&:text)

          assert_equal error_messages.uniq.count, error_messages.count
        end
      end

      describe 'when the contact country is empty' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
            post_create attrs: { contact_country_id: nil }
          end
        end

        it 'render the error' do
          post_create attrs: { contact_country_id: nil }

          assert_select "form#new_office_business_contract"
        end

        it 'does not duplicate the error message' do
          post_create attrs: { contact_country_id: nil }

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
        describe 'when creating a new client' do
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

              assert_select "div.vat_rate", Goxygene::Vat.find(vat_id).label
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

              assert_select "div.vat_rate", Goxygene::Vat.find(vat_id).label
            end
          end

          it 'creates the entry in database' do
            assert_difference 'Goxygene::OfficeBusinessContract.training_agreements.count' do
              post_create attrs: { establishment_id: nil }
            end
          end

          it 'creates all the expenses in the database' do
            assert_difference 'Goxygene::OfficeBusinessContractExpense.count' do
              post_create attrs: { establishment_id: nil }
            end
          end

          it 'sets the right values' do
            post_create attrs: { establishment_id: nil }

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
            assert_equal advance_payment,                         office_business_contract.advance_payment
            assert_equal advance_payment,                         office_business_contract.advance_payment_euros
          end

          it 'set the right values for expenses' do
            post_create attrs: { establishment_id: nil }

            expense = office_business_contract.office_business_contract_expenses.first

            assert_equal contract_expense_label,    expense.label
            assert_equal contract_expense_number,   expense.number
            assert_equal contract_expense_trainees, expense.trainees
            assert_equal contract_expense_cost,     expense.cost
            assert_equal contract_expense_total_cost, expense.total_cost
          end

          it 'sets the total for expenses' do
            post_create attrs: { establishment_id: nil }

            assert_equal contract_expense_total_cost, office_business_contract.office_business_contract_expenses.first.total_cost
          end

          it 'sets the vat' do
            post_create attrs: { establishment_id: nil }

            assert_equal office_business_contract.vat_rate.rate * office_business_contract.order_amount / 100,
                         office_business_contract.vat

            assert_equal office_business_contract.vat, office_business_contract.vat_euros
          end

          it 'sets the total' do
            post_create attrs: { establishment_id: nil }

            assert_equal office_business_contract.vat + office_business_contract.order_amount,
                         office_business_contract.total

            assert_equal office_business_contract.total, office_business_contract.total_euros
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

            assert_select "div.vat_rate", Goxygene::Vat.find(vat_id).label
          end
        end

        describe 'with some attachments' do
          it 'creates the entry in database' do
            assert_difference 'Goxygene::OfficeBusinessContract.count' do
              post_create attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]
            end
          end

          it 'creates attachments entries in the database' do
            assert_difference 'Goxygene::Document.count' do
              assert_difference 'Goxygene::OfficeBusinessContractsDocument.count' do
                post_create attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]
              end
            end
          end

          it 'creates all the expenses in the database' do
            assert_difference 'Goxygene::OfficeBusinessContractExpense.count' do
              post_create attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]
            end
          end

          it 'displays the list of attachments in the preview form'


          it 'sets the right values' do
            post_create attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]

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
            assert_equal advance_payment,                         office_business_contract.advance_payment
            assert_equal advance_payment,                         office_business_contract.advance_payment_euros
          end

          it 'set the right values for expenses' do
            post_create attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]

            expense = office_business_contract.office_business_contract_expenses.first

            assert_equal contract_expense_label,    expense.label
            assert_equal contract_expense_number,   expense.number
            assert_equal contract_expense_trainees, expense.trainees
            assert_equal contract_expense_cost,     expense.cost
            assert_equal contract_expense_total_cost, expense.total_cost
          end

          it 'sets the total for expenses' do
            post_create attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]

            assert_equal contract_expense_total_cost, office_business_contract.office_business_contract_expenses.first.total_cost
          end

          it 'sets the vat' do
            post_create attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]

            assert_equal office_business_contract.vat_rate.rate * office_business_contract.order_amount / 100,
                         office_business_contract.vat

            assert_equal office_business_contract.vat, office_business_contract.vat_euros
          end

          it 'sets the total' do
            post_create attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]

            assert_equal office_business_contract.vat + office_business_contract.order_amount,
                         office_business_contract.total

            assert_equal office_business_contract.total, office_business_contract.total_euros
          end

          it 'responds with success' do
            post_create attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]

            assert_response :success
          end

          it 'renders the preview form' do
            post_create attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]

            assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
          end

          it 'includes the client name in the preview form' do
            post_create attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]

            assert_select "div.establishment_name", establishment_name
          end

          it 'includes the VAT rate in the preview form' do
            post_create attachments: [fixture_file_upload('files/sample1.pdf', 'application/pdf')]

            assert_select "div.vat_rate", Goxygene::Vat.find(vat_id).label
          end
        end

        describe 'with a time based billing mode' do
          it 'creates the entry in database' do
            assert_difference 'Goxygene::OfficeBusinessContract.count' do
              post_create
            end
          end

          it 'creates all the expenses in the database' do
            assert_difference 'Goxygene::OfficeBusinessContractExpense.count' do
              post_create
            end
          end

          it 'sets the right values' do
            post_create

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
            assert_equal advance_payment,                         office_business_contract.advance_payment
            assert_equal advance_payment,                         office_business_contract.advance_payment_euros
          end

          it 'set the right values for expenses' do
            post_create

            expense = office_business_contract.office_business_contract_expenses.first

            assert_equal contract_expense_label,    expense.label
            assert_equal contract_expense_number,   expense.number
            assert_equal contract_expense_trainees, expense.trainees
            assert_equal contract_expense_cost,     expense.cost
            assert_equal contract_expense_total_cost, expense.total_cost
          end

          it 'sets the total for expenses' do
            post_create

            assert_equal contract_expense_total_cost, office_business_contract.office_business_contract_expenses.first.total_cost
          end

          it 'sets the vat' do
            post_create

            assert_equal office_business_contract.vat_rate.rate * office_business_contract.order_amount / 100,
                         office_business_contract.vat

            assert_equal office_business_contract.vat, office_business_contract.vat_euros
          end

          it 'sets the total' do
            post_create

            assert_equal office_business_contract.vat + office_business_contract.order_amount,
                         office_business_contract.total

            assert_equal office_business_contract.total, office_business_contract.total_euros
          end

          it 'responds with success' do
            post_create

            assert_response :success
          end

          it 'renders the preview form' do
            post_create

            assert_select "span.contract-reqest-title", 'PRÉVISUALISATION'
          end

          it 'includes the client name in the preview form' do
            post_create

            assert_select "div.establishment_name", establishment_name
          end

          it 'includes the VAT rate in the preview form' do
            post_create

            assert_select "div.vat_rate", Goxygene::Vat.find(vat_id).label
          end
        end

        describe 'with a fixed price billing mode' do
          it 'creates the entry in database' do
            assert_difference 'Goxygene::OfficeBusinessContract.count' do
              post_create attrs: {
                billing_mode: 'fixed_price',
                time_length_approx: time_length,
                time_length: nil,
                daily_order_amount: nil
              }
            end
          end

          it 'creates all the expenses in the database' do
            assert_difference 'Goxygene::OfficeBusinessContractExpense.count' do
              post_create attrs: {
                billing_mode: 'fixed_price',
                time_length_approx: time_length,
                time_length: nil,
                daily_order_amount: nil
              }
            end
          end

          it 'sets the right values' do
            post_create attrs: {
              billing_mode: 'fixed_price',
              time_length_approx: time_length,
              time_length: nil,
              daily_order_amount: nil
            }

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

            assert_equal 'fixed_price',                          office_business_contract.billing_mode
            assert_equal beginning_date,                         office_business_contract.begining_date
            assert_equal ending_date,                            office_business_contract.ending_date
            assert_equal time_length,                            office_business_contract.time_length
            assert_equal order_amount,                           office_business_contract.order_amount
            assert_equal 0,                                      office_business_contract.daily_order_amount
            assert_equal consultant_comment,                     office_business_contract.consultant_comment
            assert_equal expenses_comment,                       office_business_contract.expenses_comment
            assert_equal expenses_payback_comment,               office_business_contract.expenses_payback_comment
            assert_equal contract_handling_comment,              office_business_contract.contract_handling_comment
            assert_equal notice_period,                          office_business_contract.notice_period
            assert_equal advance_payment,                        office_business_contract.advance_payment
            assert_equal advance_payment,                        office_business_contract.advance_payment_euros
          end

          it 'set the right values for expenses' do
            post_create attrs: {
              billing_mode: 'fixed_price',
              time_length_approx: time_length,
              time_length: nil,
              daily_order_amount: nil
            }

            expense = office_business_contract.office_business_contract_expenses.first

            assert_equal contract_expense_label,    expense.label
            assert_equal contract_expense_number,   expense.number
            assert_equal contract_expense_trainees, expense.trainees
            assert_equal contract_expense_cost,     expense.cost
            assert_equal contract_expense_total_cost, expense.total_cost
          end

          it 'sets the total for expenses' do
            post_create attrs: {
              billing_mode: 'fixed_price',
              time_length_approx: time_length,
              time_length: nil,
              daily_order_amount: nil
            }

            assert_equal contract_expense_total_cost, office_business_contract.office_business_contract_expenses.first.total_cost
          end

          it 'sets the vat' do
            post_create attrs: {
              billing_mode: 'fixed_price',
              time_length_approx: time_length,
              time_length: nil,
              daily_order_amount: nil
            }

            assert_equal office_business_contract.vat_rate.rate * office_business_contract.order_amount / 100,
                         office_business_contract.vat

            assert_equal office_business_contract.vat, office_business_contract.vat_euros
          end

          it 'sets the total' do
            post_create attrs: {
              billing_mode: 'fixed_price',
              time_length_approx: time_length,
              time_length: nil,
              daily_order_amount: nil
            }

            assert_equal office_business_contract.vat + office_business_contract.order_amount,
                         office_business_contract.total

            assert_equal office_business_contract.total, office_business_contract.total_euros
          end

          it 'renders the preview form' do
            post_create attrs: {
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
              billing_mode: 'fixed_price',
              time_length_approx: time_length,
              time_length: nil,
              daily_order_amount: nil
            }

            assert_response :success

            assert_select "div.text-bold", establishment_name
          end
        end
      end
    end

    describe 'on the show action' do
      before { current_contract }

      it 'renders the PDF' do
        get "/bureau_consultant/office_training_agreements/#{current_contract.id}.pdf"

        assert_response :success
      end
    end

    # describe 'on the contract_request_show action' do
    #   CommercialContractRequestsIds.each do |contract_id|
    #     it "renders the bill #{contract_id}" do
    #       consultant = Goxygene::OfficeBusinessContract.find(contract_id).consultant

    #       sign_in CasAuthentication.find_by(cas_user_type: 'Goxygene::Consultant', cas_user_id: consultant)

    #       get "/bureau_consultant/commercial_contracts/contract_request/#{contract_id}.pdf"

    #       assert_response :success
    #     end
    #   end
    # end

    describe 'on the destroy pending action' do
      before { current_contract }

      def get_destroy_pending(attrs = {})
        get "/bureau_consultant/office_training_agreements/pending/destroy"
      end

      it 'deletes the entry from database' do
        assert_difference 'Goxygene::OfficeBusinessContract.count', -1 do
          get_destroy_pending
        end
      end

      it 'redirects to the new contract page' do
        get_destroy_pending

        assert_redirected_to '/bureau_consultant/office_training_agreements/new'
      end
    end

    describe 'on the submit action' do
      before { current_contract }

      def post_validates(attrs = {})
        post "/bureau_consultant/office_training_agreements/#{current_contract.id}/submit"
      end

      it 'does not create a new entry' do
        assert_no_difference 'Goxygene::OfficeBusinessContract.count' do
          post_validates
        end
      end

      it 'submits the contract' do
        post_validates

        assert_equal 'office_validated', current_contract.reload.business_contract_status
      end

      it 'sets the consultant_validation timestamp' do
        post_validates

        assert ((Time.now.to_i - 10)..(Time.now.to_i + 10)).include? current_contract.reload.consultant_validation.to_i
      end

      it 'redirects to contract_request_commercial_contracts_path' do
        post_validates

        assert_redirected_to '/bureau_consultant/office_training_agreements/requests'
      end

      it 'does not reset the time_length' do
        time_length = 5 + rand(123)

        current_contract.update! billing_mode: 'fixed_price',
                                 time_length: time_length

        post_validates

        assert_equal time_length, current_contract.reload.time_length
      end
    end

    # describe 'on the destroy_annex action' do
    #   describe 'when a contract is in edition' do
    #     before { current_contract_with_attachment }

    #     it 'destroy the attachment' do
    #       assert_difference 'Goxygene::OfficeBusinessContractsDocument.count', -1 do
    #         delete "/bureau_consultant/commercial_contracts/#{current_contract.id}/annexes/#{current_contract.office_business_contracts_document_ids.first}"
    #       end
    #     end

    #     it 'responds with success' do
    #       delete "/bureau_consultant/commercial_contracts/#{current_contract.id}/annexes/#{current_contract.office_business_contracts_document_ids.first}"

    #       assert_response :success
    #     end
    #   end
    # end

    describe 'on the requests history page' do

      let(:default_filter_date_lower_bound)  { Date.today.last_year.beginning_of_year }
      let(:default_filter_date_higher_bound) { Date.current.end_of_year + 6.months    }
      let(:filter_date_lower_bound)          { 2.year.ago.beginning_of_year.to_date   }
      let(:filter_date_higher_bound)         { 6.months.ago.to_date                   }

      it 'displays the contract requests history page' do
        get '/bureau_consultant/office_training_agreements/requests'
        assert_response :success
      end

      it 'displays contracts within the default date range' do
        get '/bureau_consultant/office_training_agreements/requests'

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
        get '/bureau_consultant/office_training_agreements/requests',
            params: {
              q: {
                begining_date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                begining_date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y'),
              }
            }

        # check for the filter form values
        assert_ransack_filter :begining_date_gteq, filter_date_lower_bound .strftime('%d/%m/%Y')
        assert_ransack_filter :begining_date_lteq, filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.statement_of_activities_request").each do |entry|
          entry_date = Date.parse(entry.css("td.commercial_contract_begining_date").first.content)
          assert entry_date >= filter_date_lower_bound
          assert entry_date <= filter_date_higher_bound
        end
      end
    end

    describe 'on the signed history page' do

      let(:default_filter_date_lower_bound)  { Date.today.last_year.beginning_of_year }
      let(:default_filter_date_higher_bound) { Date.current.end_of_year + 6.months    }
      let(:filter_date_lower_bound)          { 5.year.ago.beginning_of_year.to_date   }
      let(:filter_date_higher_bound)         { 6.months.ago.to_date                   }

      it 'displays the contracts signed history page' do
        get '/bureau_consultant/office_training_agreements/signed'

        assert_response :success
      end

      it 'displays contracts within the default date range' do
        get '/bureau_consultant/office_training_agreements/signed'

        # check for the filter form values
        assert_ransack_filter :begining_date_gteq, default_filter_date_lower_bound .strftime('%d/%m/%Y')
        assert_ransack_filter :begining_date_lteq, default_filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.commercial_contract").each do |entry|
          entry_date = Date.parse(entry.css("td.commercial_contract_begining_date").first.content)
          assert entry_date >= default_filter_date_lower_bound
          assert entry_date <= default_filter_date_higher_bound
        end
      end

      it 'can filter by beginning date' do
        get '/bureau_consultant/office_training_agreements/signed',
            params: {
              q: {
                begining_date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                begining_date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y'),
              }
            }

        # check for the filter form values
        assert_ransack_filter :begining_date_gteq, filter_date_lower_bound .strftime('%d/%m/%Y')
        assert_ransack_filter :begining_date_lteq, filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.statement_of_activities_request").each do |entry|
          entry_date = Date.parse(entry.css("td.commercial_contract_begining_date").first.content)
          assert entry_date >= filter_date_lower_bound
          assert entry_date <= filter_date_higher_bound
        end
      end
    end

  end

  describe 'not authenticated' do
    describe 'on the history page' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/office_training_agreements/requests'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end
  end
end

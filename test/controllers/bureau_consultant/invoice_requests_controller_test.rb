require 'test_helper'

describe BureauConsultant::InvoiceRequestsController do
  describe 'authenticated as a consultant' do

    before { sign_in cas_authentications(:jackie_denesik) }

    InvoiceRequestIds = %w{
      294259 232067 235100
    }

    InvoiceRequestIds = InvoiceRequestIds.shuffle[0..5] unless ENV['ALL']

    let(:consultant)        { Goxygene::Consultant.find 9392       }
    let(:establishment)     { consultant.establishments_from_contacts.first      }
    let(:establishment_name){ FFaker::Name.name                       }
    let(:first_name)        { FFaker::Name.first_name                 }
    let(:last_name)         { FFaker::Name.last_name.upcase           }

    let(:date)              { Date.current + rand(10).days         }
    let(:target_date)       { date + rand(5).days                  }
    let(:vat_rate)          { Goxygene::Vat.all.to_a.shuffle.first }
    let(:consultant_comment){ FFaker::Lorem.words(5).join(' ')     }

    let(:contact_type)      { Goxygene::ContactType.all.shuffle.first }
    let(:contact_role)      { Goxygene::ContactRole.all.shuffle.first }

    let(:invoice_request_line_type)   { %w{expense comment}.shuffle.first }
    let(:invoice_request_line_label)  { FFaker::Lorem.words(5).join(' ')           }
    let(:invoice_request_line_amount) { 100 + rand(12345)                          }

    let(:too_long_establishment_address) { "#{rand(99)} rue de l'adresse bien trop longue pour tenir dans ce champ ayant une limite" }
    let(:too_long_contact_address)       { "#{rand(99)} rue de l'adresse bien trop longue pour tenir dans ce champ ayant une limite" }

    let(:initial_siret)                { '73282932000074' }

    let(:invoice_request_attributes) {
      {
        establishment_vat_number: '',
        establishment_siret:      initial_siret,
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

        date:             date,
        target_date:      target_date,
        vat_id:           vat_rate.id,

        consultant_itg_establishment_id: consultant.itg_establishment_id
      }
    }

    let(:invoice_request_line_attributes) do
      {
        invoice_request_line_type: invoice_request_line_type,
        label:                     invoice_request_line_label,
        amount:                    invoice_request_line_amount
      }
    end

    def post_create(attrs = {})
      post '/bureau_consultant/invoice_requests', params: {
        office_customer_bill: invoice_request_attributes.merge(attrs)
      }
    end

    def post_add_line(attrs = {})
      post '/bureau_consultant/invoice_requests/add_line', params: {
        invoice_request_line: invoice_request_line_attributes.merge(attrs)
      }
    end

    def post_validate
      post '/bureau_consultant/invoice_requests/validate', params: {
        office_customer_bill: { consultant_comment: consultant_comment }
      }
    end

    describe 'on mobile' do
      describe 'on the history page' do

        let(:invoice_requests) do
          consultant.office_customer_bills.where("date >= ?", 1.year.ago.beginning_of_year.to_date)
        end

        it 'renders the page' do
          get '/m/bureau_consultant/invoice_requests/history'

          assert_response :success
        end

        it 'lists the invoice requests' do
          get '/m/bureau_consultant/invoice_requests/history'

          assert_select 'table tbody tr', invoice_requests.count
        end

        it 'includes the client name' do
          get '/m/bureau_consultant/invoice_requests/history'

          invoice_requests.each do |invoice_request|
            assert_select "table tbody tr#invoice_#{invoice_request.id} td.client", invoice_request.establishment.name
          end
        end

        it 'does not crash rendering requests with no company' do
          consultant.office_customer_bills.last.update_columns establishment_id: nil

          get '/m/bureau_consultant/invoice_requests/history'

          assert_response :success
        end
      end

      describe 'on the new action' do
        before { get '/m/bureau_consultant/invoice_requests/new' }

        it 'renders the page' do
          assert_response :success
        end

        it 'includes the payment types' do
          payment_types = Goxygene::PaymentType.all
          assert_select 'select#office_customer_bill_payment_type_id option', payment_types.count
        end

        it 'list all the payment types' do
          Goxygene::PaymentType.all.each do |payment_type|
            assert_select "select#office_customer_bill_payment_type_id option[value=\"#{payment_type.id}\"]",
                          payment_type.label
          end
        end

        it 'lists the vat rates' do
          assert_select 'select#office_customer_bill_vat_id option', 7

          css_select('select#office_customer_bill_vat_id option').each do |vat_value|
            assert Goxygene::Vat.active.for_bureau.find(vat_value.attributes['value'].value)
          end
        end

        it 'selects the wire transfert as the default payment method' do
          assert_select 'select#office_customer_bill_payment_type_id option[selected]', 'Virement'
        end

        it 'includes a "date d\'échéance" field' do
          assert_select 'label', "Date d'échéance"
          assert_select 'input#office_customer_bill_target_date.datepicker'
        end

        it 'has a default date set to today' do
          assert_select "input#office_customer_bill_date[value=\"#{Date.today.strftime('%d/%m/%Y')}\"]"
        end

        it 'selects the consultant country for the establishment by default' do
          assert_select "select#office_customer_bill_establishment_country_id option[value=\"#{consultant.contact_datum.country_id}\"][selected]"
        end

        it 'selects the consultant country for the contact by default' do
          assert_select "select#office_customer_bill_establishment_country_id option[value=\"#{consultant.contact_datum.country_id}\"][selected]"
        end
      end

    end

    describe 'on the add_line action' do
      before { post_create }

      describe 'with no previous lines' do
        it 'redirects to the manage_invoice page' do
          post_add_line

          assert_redirected_to '/bureau_consultant/invoice_requests/manage_invoice'
        end

        it 'adds the line in the session' do
          post_add_line

          assert       session[:invoice_request_lines].last
        end

        it 'stores the line type in session' do
          post_add_line

          assert_equal invoice_request_line_type, session[:invoice_request_lines].last['detail_type']
        end

        it 'stores the label in session' do
          post_add_line invoice_request_line_type: 'comment'

          assert_equal invoice_request_line_label, session[:invoice_request_lines].last['label']
        end

        it 'allows a maximum length of 110 for the label' do
          long_label = 'a' * 110

          post_add_line invoice_request_line_type: 'comment', label: long_label

          assert_redirected_to '/bureau_consultant/invoice_requests/manage_invoice'
          assert_equal long_label, session[:invoice_request_lines].last['label']
        end

        it 'stores the amount in session' do
          post_add_line invoice_request_line_type: 'expense'

          assert_equal invoice_request_line_amount, session[:invoice_request_lines].last['amount']
        end

        it 'does not alter the database' do
          assert_no_difference 'Goxygene::OfficeCustomerBill.count' do
            assert_no_difference 'Goxygene::OfficeCustomerBillDetail.count' do
              post_add_line
            end
          end
        end
      end
    end

    describe 'on the manage_invoice action' do

      describe 'when no previous invoice was in session' do
        it 'renders the page' do
          get '/bureau_consultant/invoice_requests/manage_invoice'

          assert_response :success
        end
      end

      describe 'when the invoice was created in session' do
        before { post_create }

        it 'renders the page' do
          get '/bureau_consultant/invoice_requests/manage_invoice'

          assert_response :success
        end

        it 'displays the correct line type for a comment' do
          post_add_line invoice_request_line_type: 'comment', amount: nil

          get '/bureau_consultant/invoice_requests/manage_invoice'

          assert_select 'select#invoice_request_line_invoice_request_line_type option[value="comment"][selected="selected"]'
        end

        it 'displays the correct line type for a line jump' do
          post_add_line invoice_request_line_type: 'jump', amount: nil, label: nil

          get '/bureau_consultant/invoice_requests/manage_invoice'

          assert_select 'select#invoice_request_line_invoice_request_line_type option[value="break"][selected="selected"]'
        end

        it 'displays the correct line type for a line jump' do
          post_add_line invoice_request_line_type: 'break', amount: nil, label: nil

          get '/bureau_consultant/invoice_requests/manage_invoice'

          assert_select 'select#invoice_request_line_invoice_request_line_type option[value="break"][selected="selected"]'
        end
      end

    end

    describe 'on the invoice_request_line edit action' do
      before do
        post_create
        post_add_line
      end

      it 'renders the page' do
        get '/bureau_consultant/invoice_requests/invoice_request_line/0/edit'

        assert_response :success
      end

      it 'sets the current_line class only one' do
        get '/bureau_consultant/invoice_requests/invoice_request_line/0/edit'

        assert_select '#invoice_request form.current_line.desktop', 1
      end
    end

    describe 'on the create action' do

      describe 'when all the fields are valid' do
        it 'saves the invoice request in session' do
          post_create

          assert_equal establishment_name,                      session[:invoice_request_office_temp_establishment].name
          assert_equal establishment.contact_datum.address_2,   session[:invoice_request_office_temp_establishment].establishment_address_2
          assert_equal establishment.contact_datum.zip_code,    session[:invoice_request_office_temp_establishment].establishment_zip_code
          assert_equal establishment.contact_datum.city,        session[:invoice_request_office_temp_establishment].establishment_city
          assert_equal establishment.contact_datum.country_id,  session[:invoice_request_office_temp_establishment].establishment_country_id
          assert_equal establishment.contact_datum.phone,       session[:invoice_request_office_temp_establishment].establishment_phone

          assert_equal last_name,                               session[:invoice_request_office_temp_establishment].contact_last_name
          assert_equal first_name,                              session[:invoice_request_office_temp_establishment].contact_first_name
          assert_equal contact_type.id,                         session[:invoice_request_office_temp_establishment].contact_type.id
          assert_equal contact_role.id,                         session[:invoice_request_office_temp_establishment].contact_role.id
          assert_equal establishment.contact_datum.country_id,  session[:invoice_request_office_temp_establishment].contact_country_id
          assert_equal establishment.contact_datum.zip_code,    session[:invoice_request_office_temp_establishment].contact_zip_code
          assert_equal establishment.contact_datum.city,        session[:invoice_request_office_temp_establishment].contact_city
          assert_equal establishment.contact_datum.phone,       session[:invoice_request_office_temp_establishment].contact_phone
          assert_equal establishment.contact_datum.email,       session[:invoice_request_office_temp_establishment].contact_email

          assert_equal date,                                   session[:invoice_request].date
          assert_equal target_date,                            session[:invoice_request].target_date
          assert_equal vat_rate.id,                            session[:invoice_request].vat_id
        end

        it 'reduce the addresses length if it is too long' do
          post_create establishment_address_2: too_long_establishment_address,
                      contact_address_2:       too_long_contact_address

          assert_equal too_long_establishment_address[0..34], session[:invoice_request_office_temp_establishment].establishment_address_2
          assert_equal too_long_contact_address[0..34],       session[:invoice_request_office_temp_establishment].contact_address_2
        end

        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeCustomerBill.count' do
            post_create
          end
        end

        it 'redirects to the manage page' do
          post_create

          assert_redirected_to '/bureau_consultant/invoice_requests/manage_invoice'
        end

        describe 'when the target_date is missing' do
          it 'sets the target_date from date' do
            post_create target_date: nil

            assert_equal date.end_of_month, session[:invoice_request].target_date
          end
        end

        describe 'when creating a new contact' do
          it 'does not create anything in database' do
            assert_no_difference 'Goxygene::OfficeCustomerBill.count' do
              post_create establishment_id: establishment.id
            end
          end

          it 'redirects to the manage page' do
            post_create establishment_id: establishment.id

            assert_redirected_to '/bureau_consultant/invoice_requests/manage_invoice'
          end

          it 'displays the manage page properly' do
            post_create establishment_id: establishment.id
            get '/bureau_consultant/invoice_requests/manage_invoice'

            assert_response :success
          end
        end
      end

      describe 'when the siret is incorrect' do
        it 'does not save the invoice request in session' do
          post_create establishment_siret: '435 253 679 435 253 679435 253 679435 253 679435 253 679'

          assert_nil session[:invoice_request]
        end

        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeCustomerBill.count' do
            post_create establishment_siret: '435 253 679 435 253 679435 253 679435 253 679435 253 679'
          end
        end

        it 'does not redirects to the manage page' do
          post_create establishment_siret: '435 253 679 435 253 679435 253 679435 253 679435 253 679'

          assert_response :success
        end

        it 'displays an error message' do
          post_create establishment_siret: '435 253 679 435 253 679435 253 679435 253 679435 253 679'

          assert_select 'div#error_explanation li', /Le SIRET doit être composé de 14 chiffres./
        end
      end

      describe 'when the VAT rate is missing' do
        it 'does not save the invoice request in session' do
          post_create vat_id: nil

          assert_nil session[:invoice_request]
        end

        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeCustomerBill.count' do
            post_create vat_id: nil
          end
        end

        it 'does not redirects to the manage page' do
          post_create vat_id: nil

          assert_response :success
        end

        it 'displays an error message' do
          post_create vat_id: nil

          assert_select 'div#error_explanation li', 'Veuillez renseigner un taux de TVA.'
        end
      end

      describe 'when the target_date is before the bill_date' do
        it 'does not save the invoice request in session' do
          post_create target_date: date - 1.day

          assert_nil session[:invoice_request]
        end

        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeCustomerBill.count' do
            post_create target_date: date - 1.day
          end
        end

        it 'does not redirects to the manage page' do
          post_create target_date: date - 1.day

          assert_response :success
        end

        it 'displays an error message' do
          post_create target_date: date - 1.day

          assert_select 'div#error_explanation li', "La date d'échéance ne peut être antérieure à la date de facturation"
        end
      end

      describe 'when the target_date is above the bill_date by more than 90 days' do
        it 'does not save the invoice request in session' do
          post_create target_date: date + 91.day

          assert_nil session[:invoice_request]
        end

        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::OfficeCustomerBill.count' do
            post_create target_date: date + 91.day
          end
        end

        it 'does not redirects to the manage page' do
          post_create target_date: date + 91.day

          assert_response :success
        end

        it 'displays an error message' do
          post_create target_date: date + 91.day

          assert_select 'div#error_explanation li', "La date d'échéance ne peut être supérieure de plus de 90 jours à la date de facturation"
        end
      end
    end

    describe 'on the validate action' do
      describe 'when everything is valid' do
        before { post_create establishment_id: establishment.id }

        let(:office_customer_bill) { consultant.office_customer_bills.order(:created_at).last }

        it 'creates an office customer bill for the consultant' do
          assert_difference 'consultant.office_customer_bills.count' do
            post_validate
          end
        end

        it 'creates an entry in the database' do
          assert_difference 'Goxygene::OfficeCustomerBill.count' do
            post_validate
          end
        end

        %i{ zip_code city country_id phone }.each do |attr|
          it "sets the establishment #{attr} attribute" do
            post_validate

            assert_equal establishment.contact_datum.send(attr),
                         office_customer_bill.send("establishment_#{attr}")
          end

          it "sets the contact #{attr} attribute" do
            post_validate

            assert_equal establishment.contact_datum.send(attr),
                         office_customer_bill.send("contact_#{attr}")
          end
        end

        it 'sets the establishment address' do
          post_validate
          assert_equal establishment.address_2, office_customer_bill.establishment_address_2
        end

        it 'sets the contact address' do
          post_validate
          assert_equal establishment.address_2[0..34], office_customer_bill.contact_address_2[0..34]
        end

        it 'sets the contact first name' do
          post_validate
          assert_equal first_name, office_customer_bill.contact_first_name
        end

        it 'sets the contact last name' do
          post_validate
          assert_equal last_name, office_customer_bill.contact_last_name
        end

        it 'sets the date' do
          post_validate
          assert_equal date, office_customer_bill.date
        end

        it 'sets the target_date' do
          post_validate
          assert_equal target_date, office_customer_bill.target_date
        end

        it 'sets the vat_id' do
          post_validate
          assert_equal vat_rate.id, office_customer_bill.vat_id
        end

        it 'sets the consultant comment' do
          post_validate
          assert_equal consultant_comment, office_customer_bill.consultant_comment
        end

        it 'sets the consultant_validation timestamp' do
          post_validate
          assert ((Time.now.to_i - 10)..(Time.now.to_i + 10)).include? office_customer_bill.consultant_validation.to_i
        end

        it 'sets the customer_id' do
          post_validate
          assert_not_nil office_customer_bill.customer
          assert_equal establishment.company.customer, office_customer_bill.customer
        end

        it 'redirects to the history page' do
          post_validate

          assert_redirected_to '/bureau_consultant/invoice_requests/history'
        end
      end

      describe 'when the addresses are too long' do
        before {
          post_create establishment_id: nil,
                      establishment_address_2: too_long_establishment_address,
                      contact_address_2: too_long_contact_address
        }

        let(:office_customer_bill) { consultant.office_customer_bills.order(:created_at).last }

        it 'creates an office customer bill for the consultant' do
          assert_difference 'consultant.office_customer_bills.count' do
            post_validate
          end
        end

        it 'creates an entry in the database' do
          assert_difference 'Goxygene::OfficeCustomerBill.count' do
            post_validate
          end
        end

        %i{ zip_code city country_id phone }.each do |attr|
          it "sets the establishment #{attr} attribute" do
            post_validate

            assert_equal establishment.contact_datum.send(attr),
                         office_customer_bill.send("establishment_#{attr}")
          end

          it "sets the contact #{attr} attribute" do
            post_validate

            assert_equal establishment.contact_datum.send(attr),
                         office_customer_bill.send("contact_#{attr}")
          end
        end

        it 'sets the establishment address' do
          post_validate
          assert_equal too_long_establishment_address[0..34], office_customer_bill.establishment_address_2
        end

        it 'sets the contact address' do
          post_validate
          assert_equal too_long_contact_address[0..34], office_customer_bill.contact_address_2
        end

        it 'sets the contact first name' do
          post_validate
          assert_equal first_name, office_customer_bill.contact_first_name
        end

        it 'sets the contact last name' do
          post_validate
          assert_equal last_name, office_customer_bill.contact_last_name
        end

        it 'sets the date' do
          post_validate
          assert_equal date, office_customer_bill.date
        end

        it 'sets the target_date' do
          post_validate
          assert_equal target_date, office_customer_bill.target_date
        end

        it 'sets the vat_id' do
          post_validate
          assert_equal vat_rate.id, office_customer_bill.vat_id
        end

        it 'sets the consultant comment' do
          post_validate
          assert_equal consultant_comment, office_customer_bill.consultant_comment
        end

        it 'sets the consultant_validation timestamp' do
          post_validate
          assert ((Time.now.to_i - 10)..(Time.now.to_i + 10)).include? office_customer_bill.consultant_validation.to_i
        end

        it 'redirects to the history page' do
          post_validate

          assert_redirected_to '/bureau_consultant/invoice_requests/history'
        end
      end

    end

    describe 'on the new action' do
      before { get '/bureau_consultant/invoice_requests/new' }

      it 'renders the page' do
        assert_response :success
      end

      it 'includes the payment types' do
        payment_types = Goxygene::PaymentType.all
        assert_select 'select#office_customer_bill_payment_type_id option', payment_types.count
      end

      it 'list all the payment types' do
        Goxygene::PaymentType.all.each do |payment_type|
          assert_select "select#office_customer_bill_payment_type_id option[value=\"#{payment_type.id}\"]",
                        payment_type.label
        end
      end

      it 'lists the vat rates' do
        assert_select 'select#office_customer_bill_vat_id option', 7

        css_select('select#office_customer_bill_vat_id option').each do |vat_value|
          assert Goxygene::Vat.active.for_bureau.find(vat_value.attributes['value'].value)
        end
      end

      it 'selects the wire transfert as the default payment method' do
        assert_select 'select#office_customer_bill_payment_type_id option[selected]', 'Virement'
      end

      it 'includes a "date d\'échéance" field' do
        assert_select 'label', "Date d'échéance"
        assert_select 'input#office_customer_bill_target_date.datepicker'
      end

      it 'has a default date set to today' do
        assert_select "input#office_customer_bill_date[value=\"#{Date.today.strftime('%d/%m/%Y')}\"]"
      end

      it 'selects the consultant country for the establishment by default' do
        assert_select "select#office_customer_bill_establishment_country_id option[value=\"#{consultant.contact_datum.country_id}\"][selected]"
      end

      it 'selects the consultant country for the contact by default' do
        assert_select "select#office_customer_bill_establishment_country_id option[value=\"#{consultant.contact_datum.country_id}\"][selected]"
      end

      it 'displays only the showonbureau list for contact_type' do
        assert Goxygene::ContactType.for_bureau.count > 0
        assert_select 'select#office_customer_bill_contact_contact_type_id option', Goxygene::ContactType.for_bureau.count
      end
    end

    describe 'on the new_from_siret action' do
      describe 'with a valid siret' do
        let(:siret) { '72130541762587' }
        let(:establishment_from_siret) { Goxygene::Establishment.find_by siret: siret }

        it 'redirects to the new page' do
          get '/bureau_consultant/invoice_requests/new_from_siret', params: { siret: siret }

          assert_redirected_to '/bureau_consultant/invoice_requests/new'
        end

        it 'does not create a new establishment' do
          assert_no_difference 'Goxygene::Establishment.count' do
            get '/bureau_consultant/invoice_requests/new_from_siret', params: { siret: siret }
          end
        end

        it 'creates a new establishment contact linked to the consultant' do
          assert_difference 'Goxygene::EstablishmentContact.count' do
            get '/bureau_consultant/invoice_requests/new_from_siret', params: { siret: siret }
          end

          assert_equal consultant, Goxygene::EstablishmentContact.last.consultant
        end
      end

      describe 'with spaces within the valid siret' do
        let(:siret) { '721 305 417 62587' }
        let(:establishment_from_siret) { Goxygene::Establishment.find_by siret: siret }

        it 'redirects to the new page' do
          get '/bureau_consultant/invoice_requests/new_from_siret', params: { siret: siret }

          assert_redirected_to '/bureau_consultant/invoice_requests/new'
        end

        it 'does not create a new establishment' do
          assert_no_difference 'Goxygene::Establishment.count' do
            get '/bureau_consultant/invoice_requests/new_from_siret', params: { siret: siret }
          end
        end

        it 'creates a new establishment contact linked to the consultant' do
          assert_difference 'Goxygene::EstablishmentContact.count' do
            get '/bureau_consultant/invoice_requests/new_from_siret', params: { siret: siret }
          end

          assert_equal consultant, Goxygene::EstablishmentContact.last.consultant
        end
      end

      describe 'with spaces and tabs within the valid siret' do
        let(:siret) { "\t721 305 417 62587" }
        let(:establishment_from_siret) { Goxygene::Establishment.find_by siret: siret }

        it 'redirects to the new page' do
          get '/bureau_consultant/invoice_requests/new_from_siret', params: { siret: siret }

          assert_redirected_to '/bureau_consultant/invoice_requests/new'
        end

        it 'does not create a new establishment' do
          assert_no_difference 'Goxygene::Establishment.count' do
            get '/bureau_consultant/invoice_requests/new_from_siret', params: { siret: siret }
          end
        end

        it 'creates a new establishment contact linked to the consultant' do
          assert_difference 'Goxygene::EstablishmentContact.count' do
            get '/bureau_consultant/invoice_requests/new_from_siret', params: { siret: siret }
          end

          assert_equal consultant, Goxygene::EstablishmentContact.last.consultant
        end
      end
    end

    describe 'on the history page' do

      let(:default_filter_date_lower_bound)  { Date.today.last_year.beginning_of_year       }
      let(:default_filter_date_higher_bound) { Date.current.end_of_year + 6.months          }
      let(:filter_date_lower_bound)          { 3.year.ago.beginning_of_year.to_date         }
      let(:filter_date_higher_bound)         { 6.months.from_now.beginning_of_month.to_date }

      let(:invoice_requests) do
        consultant.office_customer_bills.where("date >= ?", 1.year.ago.beginning_of_year.to_date)
      end

      it 'renders the page' do
        get '/bureau_consultant/invoice_requests/history'

        assert_response :success
      end

      it 'lists the invoice requests' do
        get '/bureau_consultant/invoice_requests/history'

        assert_select 'table tbody tr', invoice_requests.count
      end

      it 'includes the client name' do
        get '/bureau_consultant/invoice_requests/history'

        invoice_requests.each do |invoice_request|
          assert_select "table tbody tr#invoice_#{invoice_request.id} td.client", invoice_request.establishment.name
        end
      end

      it 'sorts by date desc by default' do
        get '/bureau_consultant/invoice_requests/history',
            params: {
              q: {
                date_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%m/%Y'),
              }
            }

        previous_entry = nil

        css_select("tr.invoice_request").each do |entry|
          entry_date = Date.parse(entry.css("td.invoice_request_date").first.content)

          if previous_entry
            assert previous_entry >= entry_date
          end

          previous_entry = entry_date
        end
      end

      it 'includes both validated and non validated invoice requests' do
        get '/bureau_consultant/invoice_requests/history',
            params: {
              q: {
                date_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%m/%Y')
              }
            }

        assert_select 'tr.invoice_request td.status', 'Oui'
        assert_select 'tr.invoice_request td.status', 'Non'
      end

      it 'has a link to sort by client name' do
        get '/bureau_consultant/invoice_requests/history'

        assert css_select('a.sort_link').any? { |link| link.attribute('href').value.match /establishment_name\+asc/ }
      end

      it 'can sort asc by client name' do
        get '/bureau_consultant/invoice_requests/history',
            params: {
              q: {
                date_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%m/%Y'),
                s: 'establishment_name asc'
              }
            }

        assert_tabledata_order(selector: 'tr.invoice_request',
                               field: 'client') { |entry, previous|

          previous.content.downcase <= entry.content.downcase

        }
      end

      it 'can sort desc by client name' do
        get '/bureau_consultant/invoice_requests/history',
            params: {
              q: {
                date_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%m/%Y'),
                s: 'establishment_name desc'
              }
            }

        assert_tabledata_order(selector: 'tr.invoice_request',
                               field: 'client') { |entry, previous|

          previous.content.downcase >= entry.content.downcase

        }
      end

      it 'does not crash rendering requests with no company' do
        consultant.office_customer_bills.last.update_columns establishment_id: nil

        get '/bureau_consultant/invoice_requests/history'

        assert_response :success
      end
    end

    describe 'on the export page' do
      let(:workbook) { RubyXL::Parser.parse_buffer(response.body) }

      before do
        get '/bureau_consultant/invoice_requests/history/export.xlsx',
            params: {
              q: {
                id_in: consultant.office_customer_bill_ids,
                date_gteq: 10.years.ago.strftime('%m/%Y'),
                date_lteq: 10.years.from_now.strftime('%m/%Y')
              }
            }
      end

      it 'responds with success' do
        assert_response :success
      end

      it 'includes the status' do
        assert %w{Oui Non}.include? workbook[0][1][8].value
      end

      it 'includes the date' do
        assert Date.parse(workbook[0][1][1].value)
      end

      it 'does not format the amount of fees' do
        assert workbook[0][1][4].value.is_a?(Float) || workbook[0][1][4].value.is_a?(Integer)
      end

      it 'does not format the amount of expenses' do
        assert workbook[0][1][5].value.is_a?(Float) || workbook[0][1][5].value.is_a?(Integer)
      end

      it 'does not format the total amount without taxes' do
        assert workbook[0][1][6].value.is_a?(Float) || workbook[0][1][6].value.is_a?(Integer)
      end

      it 'does not format the total amount with taxes' do
        assert workbook[0][1][7].value.is_a?(Float) || workbook[0][1][7].value.is_a?(Integer)
      end


    end

    describe 'on the history show action' do
      InvoiceRequestIds.each do |invoice_request_id|
        it "renders the invoice request #{invoice_request_id}" do
          consultant = Goxygene::OfficeCustomerBill.find(invoice_request_id).consultant

          sign_in CasAuthentication.find_by(cas_user_type: 'Goxygene::Consultant', cas_user_id: consultant)

          get "/bureau_consultant/invoice_requests/history/#{invoice_request_id}.pdf"

          assert_response :success
        end
      end

      describe 'with an invoice with no customer' do
        let(:invoice_request_id) { 294388 }

        it 'renders the invoice request PDF' do
          consultant = Goxygene::OfficeCustomerBill.find(invoice_request_id).consultant

          sign_in CasAuthentication.find_by(cas_user_type: 'Goxygene::Consultant', cas_user_id: consultant)

          get "/bureau_consultant/invoice_requests/history/#{invoice_request_id}.pdf"

          assert_response :success
        end
      end
    end

    describe 'on the synthesis action' do
      let(:fees_amounts)     { [ 100+rand(1234), 100+rand(1234), 100+rand(1234) ] }
      let(:expenses_amounts) { [ 100+rand(1234), 100+rand(1234), 100+rand(1234) ] }

      let(:total_fees)       { fees_amounts.sum              }
      let(:total_expenses)   { expenses_amounts.sum          }
      let(:total)            { total_fees + total_expenses   }
      let(:total_with_taxes) { total * (1+vat_rate.rate/100) }

      describe 'when using the default (€) currency' do
        let(:consultant_credit) do
          (total_fees * consultant.consultant_margin / 100) + total_expenses
        end

        before do
          post_create

          fees_amounts    .each { |amount| post_add_line invoice_request_line_type: 'fee',     amount: amount }
          expenses_amounts.each { |amount| post_add_line invoice_request_line_type: 'expense', amount: amount }

          get '/bureau_consultant/invoice_requests/synthesis'
        end

        it 'renders the page' do
          assert_response :success
        end

        it 'computes the right total' do
          assert_equal total_with_taxes.to_i,
                       css_select('div.c3ValueSalaireConventionel').first.attributes['data-value'].value.to_i
        end

        it 'computes the right total fees' do
          skip 'was pointing to a masked div, to be fixed'
          assert_select "div.c1ValueJour.fees[data-value=\"#{total_fees.to_f}\"]", 1
        end

        it 'computes the right total expenses' do
          skip 'was pointing to a masked div, to be fixed'
          assert_select "div.c2ValueHeure.expenses[data-value=\"#{total_expenses.to_f}\"]", 1
        end

        it 'computes the right credit for consultant' do
          assert_equal consultant_credit.to_i,
                       css_select('div.consultant_credit').first.attributes['data-value'].value.to_i
        end
      end

      describe 'when using the $ currency' do
        let(:currency)  { Goxygene::Currency.find_by(short_name: 'USD') }
        let(:change)    { currency.change                               }
        let(:consultant_credit) do
          ((total_fees * change) * (consultant.consultant_margin / 100)) + (total_expenses * change)
        end

        before do
          post_create currency_id: currency.id

          fees_amounts    .each { |amount| post_add_line invoice_request_line_type: 'fee',     amount: amount }
          expenses_amounts.each { |amount| post_add_line invoice_request_line_type: 'expense', amount: amount }

          get '/bureau_consultant/invoice_requests/synthesis'
        end

        it 'renders the page' do
          assert_response :success
        end

        it 'computes the right total' do
          assert_equal total_with_taxes.to_i,
                       css_select('div.c3ValueSalaireConventionel').first.attributes['data-value'].value.to_i
        end

        it 'computes the right total fees' do
          skip 'was pointing to a masked div, to be fixed'
          assert_select "div.c1ValueJour.fees[data-value=\"#{total_fees.to_f}\"]", 1
        end

        it 'computes the right total expenses' do
          skip 'was pointing to a masked div, to be fixed'
          assert_select "div.c2ValueHeure.expenses[data-value=\"#{total_expenses.to_f}\"]", 1
        end

        it 'computes the right credit for consultant' do
          assert_equal consultant_credit.to_i,
                       css_select("div.consultant_credit").first.attributes['data-value'].value.to_i
        end

        it 'checks if change is not equal to 1.0' do
          assert change != 1.0
        end
      end

    end

  end
end

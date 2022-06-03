require 'test_helper'

describe BureauConsultant::BillingsController do
  describe 'authenticated as a consultant' do

    let(:consultant)  { Goxygene::Consultant.find 10042 }

    before { sign_in cas_authentications(:kurtis_grant) }

    BillingIds = %w{
      388263 447442
    }

    BillingIds = BillingIds.shuffle[0..5] unless ENV['ALL']

    let(:invoices)   { [ Goxygene::CustomerBill.find(447442) ] }

    describe 'on mobile' do
      describe 'on the history page' do
        it 'renders the page' do
          get '/m/bureau_consultant/billings/history'

          assert_response :success
        end

        it 'lists the bills' do
          get '/m/bureau_consultant/billings/history'

          assert_select 'div.billing'
        end

        it 'translate the billing type field' do
          get '/m/bureau_consultant/billings/history'

          assert_select 'div.billing span', 'Facture'
        end
      end
    end

    describe 'on the history page' do
      let(:default_filter_date_lower_bound)  { Date.today.last_year.beginning_of_year       }
      let(:default_filter_date_higher_bound) { Date.current.end_of_year + 6.months          }
      let(:filter_date_lower_bound)          { 3.year.ago.beginning_of_year.to_date         }
      let(:filter_date_higher_bound)         { 6.months.from_now.beginning_of_month.to_date }

      it 'renders the page' do
        get '/bureau_consultant/billings/history'

        assert_response :success
      end

      it 'lists the bills' do
        get '/bureau_consultant/billings/history'

        assert_select 'table tbody tr', 1
      end

      it 'translate the billing type field' do
        get '/bureau_consultant/billings/history'

        assert_select 'table tbody tr td', 'Facture'
      end

      it 'includes the client name' do
        get '/bureau_consultant/billings/history'

        invoices.each do |invoice|
          assert_select "table tbody tr#invoice_#{invoice.id} td.client", invoice.establishment.name.truncate(35)
        end
      end

      it 'includes a checkbox for xls export' do
        get '/bureau_consultant/billings/history'

        assert_select 'input[type="checkbox"][name="q[id_in][]"]'
      end

      it 'displays invoices within the default date range' do
        get '/bureau_consultant/billings/history'

        # check for the filter form values
        assert_ransack_filter :date_gteq, default_filter_date_lower_bound .strftime('%d/%m/%Y')
        assert_ransack_filter :date_lteq, default_filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.invoice").each do |entry|
          entry_date = Date.parse(entry.css("td.invoice_date").first.content)
          assert entry_date >= default_filter_date_lower_bound
          assert entry_date <= default_filter_date_higher_bound
        end
      end

      it 'sorts by date desc by default' do
        get '/bureau_consultant/billings/history',
            params: {
              q: {
                date_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%m/%Y'),
              }
            }

        previous_entry = nil

        css_select("tr.invoice").each do |entry|
          entry_date = Date.parse(entry.css("td.invoice_date").first.content)

          if previous_entry
            assert previous_entry >= entry_date
          end

          previous_entry = entry_date
        end
      end

      it 'can filter by date' do
        get '/bureau_consultant/billings/history',
            params: {
              q: {
                date_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%m/%Y'),
              }
            }

        # check for the filter form values
        assert_ransack_filter :date_gteq, filter_date_lower_bound .strftime('%d/%m/%Y')
        assert_ransack_filter :date_lteq, filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.invoice").each do |entry|
          entry_date = Date.parse(entry.css("td.invoice_date").first.content)
          assert entry_date >= filter_date_lower_bound
          assert entry_date <= filter_date_higher_bound
        end
      end

      it 'can filter outstanding bills' do
        get '/bureau_consultant/billings/history',
            params: {
              q: {
                date_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%m/%Y'),
                outstanding: "1"
              }
            }

        # check for the filter form values
        consultant.customer_bills.outstanding.each do |invoice|
          assert_select "table tbody tr#invoice_#{invoice.id} td.client", invoice.establishment.name.truncate(35)
        end
      end

      it 'has a link to sort by client name' do
        get '/bureau_consultant/billings/history'

        assert css_select('a.sort_link').any? { |link| link.attribute('href').value.match /establishment_name\+asc/ }
      end

      it 'can sort asc by client name' do
        get '/bureau_consultant/billings/history',
            params: {
              q: {
                date_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%m/%Y'),
                s: 'establishment_name asc'
              }
            }

        assert_tabledata_order(selector: 'tr.invoice',
                               field: 'client') { |entry, previous|

          previous.content.downcase <= entry.content.downcase

        }
      end

      it 'can sort desc by client name' do
        get '/bureau_consultant/billings/history',
            params: {
              q: {
                date_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%m/%Y'),
                s: 'establishment_name desc'
              }
            }

        assert_tabledata_order(selector: 'tr.invoice',
                               field: 'client') { |entry, previous|

          previous.content.downcase >= entry.content.downcase

        }
      end

      describe 'when the bill does not have a bill_number' do
        before { consultant.customer_bills.each { |bill| bill.update_columns bill_number: nil } }

        it 'renders the page' do
          get '/bureau_consultant/billings/history'

          assert_response :success
        end

      end
    end

    describe 'on the export page' do
      let(:workbook) { RubyXL::Parser.parse_buffer(response.body) }

      before do
        get '/bureau_consultant/billings/history/export.xlsx',
            params: { q: { id_in: consultant.customer_bill_ids } }
      end

      it 'responds with success' do
        assert_response :success
      end

      it 'translates the status' do
        assert_equal "Facture", workbook[0][1][0].value
      end

      it 'includes the date' do
        assert Date.parse(workbook[0][1][1].value)
      end

      it 'does not format the amount of fees' do
        assert workbook[0][1][5].value.is_a?(Float) || workbook[0][1][5].value.is_a?(Integer)
      end

      it 'does not format the amount of expenses' do
        assert workbook[0][1][6].value.is_a?(Float) || workbook[0][1][6].value.is_a?(Integer)
      end

      it 'does not format the total amount without taxes' do
        assert workbook[0][1][7].value.is_a?(Float) || workbook[0][1][7].value.is_a?(Integer)
      end

      it 'does not format the total amount of taxes' do
        assert workbook[0][1][8].value.is_a?(Float) || workbook[0][1][8].value.is_a?(Integer)
      end

      it 'does not format the total amount with taxes' do
        assert workbook[0][1][9].value.is_a?(Float) || workbook[0][1][9].value.is_a?(Integer)
      end

      it 'does not format the total amount remaining' do
        assert workbook[0][1][10].value.is_a?(Float) || workbook[0][1][10].value.is_a?(Integer)
      end

    end

    describe 'on the history show action' do
      BillingIds.each do |bill_id|
        it "renders the bill #{bill_id}" do
          consultant = Goxygene::CustomerBill.find(bill_id).consultant

          sign_in CasAuthentication.find_by(cas_user_type: 'Goxygene::Consultant', cas_user_id: consultant)

          get "/bureau_consultant/billings/history/#{bill_id}.pdf"

          assert_response :success
        end
      end
    end

  end
end

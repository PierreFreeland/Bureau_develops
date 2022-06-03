require 'test_helper'

describe BureauConsultant::AccountsController do
  describe 'authenticated as a consultant' do
    before { sign_in cas_authentications(:jackie_denesik) }

    let(:consultant) { Goxygene::Consultant.find 9392 }

    let(:balances)   { OpenStruct.new id: consultant.id, cash: 99999.0, activity: 99999, invoicing: 0.0 }
    let(:financial_entries) {
      [
        OpenStruct.new(id:"0171NB1709", date:"2017-02-27T00:00:00.000Z", entry_id:9, label:"NDF 27/2 REF 229695                     ", lettree:nil, journal:"NDF ", company:"009", account:"4681000000", credit:0.0, debit:3528.61, balance:10318.7),
        OpenStruct.new(id:"0108SB1709", date:"2017-02-28T00:00:00.000Z", entry_id:4, label:"SAL FEV NET                             ", lettree:nil, journal:"SAL ", company:"009", account:"4681000000", credit:0.0, debit:5101.29, balance:10318.7),
        OpenStruct.new(id:"0108SB1709", date:"2017-02-28T00:00:00.000Z", entry_id:8, label:"SAL FEV CHARGES                         ", lettree:nil, journal:"SAL ", company:"009", account:"4681000000", credit:0.0, debit:4734.93, balance:5583.77),
        OpenStruct.new(id:"1702000073", date:"2017-02-28T00:00:00.000Z", entry_id:7, label:"Prestation AJAFA 02-2017                ", lettree:nil, journal:"GEN ", company:"009", account:"4681000000", credit:9500.0, debit:0.0, balance:15083.77),
        OpenStruct.new(id:"0110NC1709", date:"2017-03-16T00:00:00.000Z", entry_id:7, label:"NDF 16/3 REF 230974                     ", lettree:nil, journal:"NDF ", company:"009", account:"4681000000", credit:97.32, debit:0.0, balance:17814.53),
        OpenStruct.new(id:"0110NC1709", date:"2017-03-16T00:00:00.000Z", entry_id:9, label:"NDF 16/3 REF 230974                     ", lettree:nil, journal:"NDF ", company:"009", account:"4681000000", credit:0.0, debit:2633.44, balance:15181.09),
        OpenStruct.new(id:"0112NC1709", date:"2017-03-16T00:00:00.000Z", entry_id:4, label:"NDF 16/3 REF 230975                     ", lettree:nil, journal:"NDF ", company:"009", account:"4681000000", credit:76.69, debit:0.0, balance:15334.47),
        OpenStruct.new(id:"0112NC1709", date:"2017-03-16T00:00:00.000Z", entry_id:6, label:"NDF 16/3 REF 230975                     ", lettree:nil, journal:"NDF ", company:"009", account:"4681000000", credit:0.0, debit:2692.17, balance:12642.3),
        OpenStruct.new(id:"1703000033", date:"2017-03-20T00:00:00.000Z", entry_id:1, label:"RETROCESSION NDF DEPLAC ITG 03/01/17    ", lettree:nil, journal:"GEN ", company:"009", account:"4681000000", credit:411.26, debit:0.0, balance:13053.56),
      ]
    }
    let(:billing_entries) {
      [
        OpenStruct.new(id:"0311FC1809", date:"2018-03-31T00:00:00.000Z", entry_id:2, label:"FCT 4/0311FC1809 CSRSP 590              ", lettree:nil, journal:"FCT ", company:"009", account:"4683000000", credit:531.0, debit:0.0, balance:-21519.58),
        OpenStruct.new(id:"0316FC1809", date:"2018-03-31T00:00:00.000Z", entry_id:2, label:"FCT 11/0316FC1809 CFTOP 3000            ", lettree:"834", journal:"FCT ", company:"009", account:"4683000000", credit:2700.0, debit:0.0, balance:-18819.58),
        OpenStruct.new(id:"0127ED1809", date:"2018-04-10T00:00:00.000Z", entry_id:4, label:"ENC : 11 / 0316FC1809 CFTOP3000         ", lettree:"834", journal:"ENC ", company:"009", account:"4683000000", credit:0.0, debit:2700.0, balance:-6569.58),
        OpenStruct.new(id:"0001EE1809", date:"2018-05-02T00:00:00.000Z", entry_id:4, label:"ENC : 4 / 0311FC1809 CSRSP590           ", lettree:nil, journal:"ENC ", company:"009", account:"4683000000", credit:0.0, debit:531.0, balance:-30008.43)
      ]
    }
    let(:treasury_entries) {
      [
        OpenStruct.new(id:"0140SK1509", date:"2015-11-30T00:00:00.000Z", entry_id:3, label:"SAL NOV                                 ", lettree:nil, journal:"SAL ", company:"009", account:"4684000000", credit:933.88, debit:0.0, balance:2233.39),
        OpenStruct.new(id:"1512000001", date:"2015-12-01T00:00:00.000Z", entry_id:6, label:"FCT APPLE DISTRIBUTION 4527310498       ", lettree:nil, journal:"ACH ", company:"009", account:"4684000000", credit:1099.0, debit:0.0, balance:3332.39),
        OpenStruct.new(id:"0078VL1509", date:"2015-12-03T00:00:00.000Z", entry_id:1, label:"PMT AVANCE387697                        ", lettree:nil, journal:"VIR ", company:"009", account:"4684000000", credit:0.0, debit:5000.0, balance:-1484.44),
        OpenStruct.new(id:"0097NL1509", date:"2015-12-16T00:00:00.000Z", entry_id:1, label:"NDF 16/12 REF 206212                    ", lettree:nil, journal:"NDF ", company:"009", account:"4684000000", credit:258.45, debit:0.0, balance:-1225.99),
        OpenStruct.new(id:"0098NL1509", date:"2015-12-16T00:00:00.000Z", entry_id:1, label:"NDF 16/12 REF 206216                    ", lettree:nil, journal:"NDF ", company:"009", account:"4684000000", credit:488.09, debit:0.0, balance:-737.9),
        OpenStruct.new(id:"0099NL1509", date:"2015-12-16T00:00:00.000Z", entry_id:1, label:"NDF 16/12 REF 206215                    ", lettree:nil, journal:"NDF ", company:"009", account:"4684000000", credit:607.35, debit:0.0, balance:-130.55),
        OpenStruct.new(id:"0100NL1509", date:"2015-12-16T00:00:00.000Z", entry_id:1, label:"NDF 16/12 REF 206213                    ", lettree:nil, journal:"NDF ", company:"009", account:"4684000000", credit:2308.73, debit:0.0, balance:2178.18),
        OpenStruct.new(id:"0101NL1509", date:"2015-12-16T00:00:00.000Z", entry_id:1, label:"NDF 16/12 REF 206214                    ", lettree:nil, journal:"NDF ", company:"009", account:"4684000000", credit:3323.44, debit:0.0, balance:5501.62),
        OpenStruct.new(id:"0102NL1509", date:"2015-12-16T00:00:00.000Z", entry_id:1, label:"NDF 16/12 REF 206217                    ", lettree:nil, journal:"NDF ", company:"009", account:"4684000000", credit:8838.55, debit:0.0, balance:14340.17),
        OpenStruct.new(id:"0186VL1509", date:"2015-12-16T00:00:00.000Z", entry_id:1, label:"PMT NDF 206217388638                    ", lettree:nil, journal:"VIR ", company:"009", account:"4684000000", credit:0.0, debit:6568.09, balance:7772.08),
        OpenStruct.new(id:"1512000005", date:"2015-12-28T00:00:00.000Z", entry_id:5, label:"FCT PRICEMINISTER 233902325             ", lettree:nil, journal:"ACH ", company:"009", account:"4684000000", credit:649.46, debit:0.0, balance:8421.54),
        OpenStruct.new(id:"1601000002", date:"2016-01-01T00:00:00.000Z", entry_id:31, label:"FCT AMAZON.FR                           ", lettree:nil, journal:"ACH ", company:"009", account:"4684000000", credit:1692.42, debit:0.0, balance:4242.86),
      ]
    }

    let(:default_filter_date_lower_bound)  { 1.year.ago.beginning_of_year.to_date }
    let(:default_filter_date_higher_bound) { Date.current.end_of_year + 6.months  }
    let(:filter_date_lower_bound)          { 2.year.ago.beginning_of_year.to_date }
    let(:filter_date_higher_bound)         { 6.months.ago.to_date                 }

    let(:workbook) { RubyXL::Parser.parse_buffer(response.body) }

    describe 'on a mobile' do
      describe 'on the pending costs page' do
        it 'renders the page' do
          get '/m/bureau_consultant/accounts/pending_costs'

          assert_response :success
        end
      end

      describe 'on the financial details page' do
        before do
          Rails.cache.clear
          Accountancy = Minitest::Mock.new
          Accountancy.expect(
            :accounting_entries,
            financial_entries,
            [{
              accounts: ['4681000000'],
              tier_pairs: { consultant.itg_company.account_tier => consultant.accountancy_code },
              collective: 'CNT',
              sort_order: 'DESC'
            }]
          )
        end

        it 'renders the page' do
          get '/m/bureau_consultant/accounts/financial'

          assert_response :success
        end

        it 'calls the accountancy api' do
          get '/m/bureau_consultant/accounts/financial'

          assert_mock Accountancy
        end
      end

      describe 'on the billing details page' do
        before do
          Rails.cache.clear
          Accountancy = Minitest::Mock.new
          Accountancy.expect(
            :accounting_entries,
            billing_entries,
            [{
              accounts: ['4683000000'],
              tier_pairs: { consultant.itg_company.account_tier => consultant.accountancy_code },
              collective: 'CNT',
              sort_order: 'DESC'
            }]
          )
        end

        it 'renders the page' do
          get '/m/bureau_consultant/accounts/billing'

          assert_response :success
        end

        it 'calls the accountancy api' do
          get '/m/bureau_consultant/accounts/billing'

          assert_mock Accountancy
        end
      end

      describe 'on the treasury details page' do
        before do
          Rails.cache.clear
          Accountancy = Minitest::Mock.new
          Accountancy.expect(
            :accounting_entries,
            treasury_entries,
            [{
              accounts: ['4684000000'],
              tier_pairs: { consultant.itg_company.account_tier => consultant.accountancy_code },
              collective: 'CNT',
              sort_order: 'DESC'
            }]
          )
        end

        it 'renders the page' do
          get '/m/bureau_consultant/accounts/treasury'

          assert_response :success
        end

        it 'calls the accountancy api' do
          get '/m/bureau_consultant/accounts/treasury'

          assert_mock Accountancy
        end
      end

      describe 'on the salary page' do

        it 'displays the wages history page' do
          get '/m/bureau_consultant/accounts/salary'
          assert_response :success
        end

        it 'displays the right requested_at date' do
          get '/m/bureau_consultant/accounts/salary'

          css_select("tr.wage").each do |wage|
            wage_id = wage.css('input[type="checkbox"]').first.attributes['value'].value
            date = Goxygene::Wage.find(wage_id).activity_report&.office_activity_report&.consultant_validation&.strftime('%d/%m/%Y')

            if date
              assert_equal date, wage.css('td.wage_requested_at').first.content
            end
          end
        end

        it 'displays a link to download the PDF' do
          get '/m/bureau_consultant/accounts/salary'

          css_select("tr.wage").each do |wage|
            wage_id = wage.css('input[type="checkbox"]').first.attributes['value'].value
            db_entry = Goxygene::Wage.find(wage_id)

            if db_entry.document
              assert_equal "\"/bureau_consultant/salaries/#{wage_id}/download.pdf\"",
                           wage.css('td.download a').first.attributes['href'].value.inspect
            end
          end
        end
      end

      describe 'on the transfers page' do
        it 'renders the page' do
          get '/m/bureau_consultant/accounts/transfers'

          assert_response :success
        end
      end

    end

    describe 'in the headers' do
      it 'displays the next salary' do
        get '/bureau_consultant/accounts/pending_costs'

        assert_select 'div.salary.value', '6 482,49 €'
      end

      it 'displays the next expenses to be reimbursed' do
        get '/bureau_consultant/accounts/pending_costs'

        assert_select 'div.expenses.value', '2 547,19 €'
      end
    end

    describe 'on the financial details page' do
      before do
        Rails.cache.clear
        Accountancy = Minitest::Mock.new
        Accountancy.expect(
          :accounting_entries,
          financial_entries,
          [{
            accounts: ['4681000000'],
            tier_pairs: { consultant.itg_company.account_tier => consultant.accountancy_code },
            collective: 'CNT',
              sort_order: 'DESC'
          }]
        )
      end

      it 'renders the page' do
        get '/bureau_consultant/accounts/financial'

        assert_response :success
      end

      it 'calls the accountancy api' do
        get '/bureau_consultant/accounts/financial'

        assert_mock Accountancy
      end
    end

    describe 'on the billing details page' do
      before do
        Rails.cache.clear
        Accountancy = Minitest::Mock.new
        Accountancy.expect(
          :accounting_entries,
          billing_entries,
          [{
            accounts: ['4683000000'],
            tier_pairs: { consultant.itg_company.account_tier => consultant.accountancy_code },
            collective: 'CNT',
              sort_order: 'DESC'
          }]
        )
      end

      it 'renders the page' do
        get '/bureau_consultant/accounts/billing'

        assert_response :success
      end

      it 'calls the accountancy api' do
        get '/bureau_consultant/accounts/billing'

        assert_mock Accountancy
      end
    end

    describe 'on the treasury details page' do
      before do
        Rails.cache.clear
        Accountancy = Minitest::Mock.new
        Accountancy.expect(
          :accounting_entries,
          treasury_entries,
          [{
            accounts: ['4684000000'],
            tier_pairs: { consultant.itg_company.account_tier => consultant.accountancy_code },
            collective: 'CNT',
              sort_order: 'DESC'
          }]
        )
      end

      it 'renders the page' do
        get '/bureau_consultant/accounts/treasury'

        assert_response :success
      end

      it 'calls the accountancy api' do
        get '/bureau_consultant/accounts/treasury'

        assert_mock Accountancy
      end
    end

    describe 'on the transfers page' do
      it 'renders the page' do
        get '/bureau_consultant/accounts/transfers'

        assert_response :success
      end

      it 'displays pending costs within the default date range' do
        get '/bureau_consultant/accounts/transfers'

        # check for the filter form values
        assert_ransack_filter :date_gteq, default_filter_date_lower_bound .strftime('%d/%m/%Y')
        assert_ransack_filter :date_lteq, default_filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.transfer").each do |entry|
          entry_date = Date.parse(entry.css("td.transfer_date").first.content)

          assert entry_date >= default_filter_date_lower_bound
          assert entry_date <= default_filter_date_higher_bound
        end
      end

      it 'can filter by creation date' do
        get '/bureau_consultant/accounts/transfers',
            params: {
              q: {
                date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y'),
              }
            }

        # check for the filter form values
        assert_ransack_filter :date_gteq, filter_date_lower_bound .strftime('%d/%m/%Y')
        assert_ransack_filter :date_lteq, filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.transfer").each do |entry|
          entry_date = Date.parse(entry.css("td.transfer_date").first.content)

          assert entry_date >= filter_date_lower_bound
          assert entry_date <= filter_date_higher_bound
        end
      end

      it 'includes a checkbox for xls export' do
        get '/bureau_consultant/accounts/transfers'

        assert_select 'input[type="checkbox"][name="q[id_in][]"]'
      end

    end

    describe 'on the export_transfers page' do
      before do
        get '/bureau_consultant/accounts/transfers/export.xlsx',
            params: { q: { id_in: consultant.disbursement_ids } }
      end

      it 'responds with success' do
        assert_response :success
      end
    end


    describe 'on the pending_costs page' do
      it 'renders the page' do
        get '/bureau_consultant/accounts/pending_costs'

        assert_response :success
      end

      it 'displays pending costs within the default date range' do
        get '/bureau_consultant/accounts/pending_costs'

        # check for the filter form values
        assert_ransack_filter :date_gteq, default_filter_date_lower_bound .strftime('%d/%m/%Y')
        assert_ransack_filter :date_lteq, default_filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.pending_cost").each do |entry|
          entry_date = Date.parse(entry.css("td.pending_cost_date").first.content)

          assert entry_date >= default_filter_date_lower_bound
          assert entry_date <= default_filter_date_higher_bound
        end
      end

      it 'can filter by creation date' do
        get '/bureau_consultant/accounts/pending_costs',
            params: {
              q: {
                date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y'),
              }
            }

        # check for the filter form values
        assert_ransack_filter :date_gteq, filter_date_lower_bound .strftime('%d/%m/%Y')
        assert_ransack_filter :date_lteq, filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.pending_cost").each do |entry|
          entry_date = Date.parse(entry.css("td.pending_cost_date").first.content)

          assert entry_date >= filter_date_lower_bound
          assert entry_date <= filter_date_higher_bound
        end
      end

      it 'includes a checkbox for xls export' do
        get '/bureau_consultant/accounts/pending_costs'

        assert_select 'input[type="checkbox"][name="q[id_in][]"]'
      end

    end

    describe 'on the export_paid_costs page' do
      before do
        get '/bureau_consultant/accounts/paid_costs/export.xlsx',
            params: { q: { id_in: consultant.expense_reports.paid.collect(&:id) } }
      end

      it 'responds with success' do
        assert_response :success
      end
    end

    describe 'on the paid_costs page' do
      it 'renders the page' do
        get '/bureau_consultant/accounts/paid_costs'

        assert_response :success
      end

      it 'includes the Chrono value' do
        get '/bureau_consultant/accounts/paid_costs'

        assert_select 'table tr.paid_cost td.chrono'

        assert !css_select('table tr.paid_cost td.chrono').first.content.empty?
      end

      it 'displays pending costs within the default date range' do
        get '/bureau_consultant/accounts/paid_costs'

        # check for the filter form values
        assert_ransack_filter :date_gteq, default_filter_date_lower_bound .strftime('%d/%m/%Y')
        assert_ransack_filter :date_lteq, default_filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.paid_cost").each do |entry|
          entry_date = Date.parse(entry.css("td.paid_cost_date").first.content)

          assert entry_date >= default_filter_date_lower_bound
          assert entry_date <= default_filter_date_higher_bound
        end
      end

      it 'can filter by creation date' do
        get '/bureau_consultant/accounts/paid_costs',
            params: {
              q: {
                date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y'),
              }
            }

        # check for the filter form values
        assert_ransack_filter :date_gteq, filter_date_lower_bound .strftime('%d/%m/%Y')
        assert_ransack_filter :date_lteq, filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.paid_cost").each do |entry|
          entry_date = Date.parse(entry.css("td.paid_cost_date").first.content)

          assert entry_date >= filter_date_lower_bound
          assert entry_date <= filter_date_higher_bound
        end
      end

      it 'includes a checkbox for xls export' do
        get '/bureau_consultant/accounts/paid_costs'

        assert_select 'input[type="checkbox"][name="q[id_in][]"]'
      end

    end

    describe 'on the export_salary page' do
      before do
        get '/bureau_consultant/accounts/salary/export.xlsx',
            params: { q: { id_in: consultant.wage_ids } }
      end

      it 'responds with success' do
        assert_response :success
      end

      it 'does not format the hours' do
        assert workbook[0][1][3].value.is_a? Float
      end

      it 'does not format the supplementary_gross_wage' do
        assert workbook[0][1][4].value.is_a? Float
      end

      it 'does not format the gross_wage' do
        assert workbook[0][1][5].value.is_a? Float
      end

      it 'does not format the net_wage' do
        assert workbook[0][1][6].value.is_a? Float
      end

      it 'does not format the cost' do
        assert workbook[0][1][7].value.is_a? Float
      end
    end

    describe 'on the salary page' do

      it 'displays the wages history page' do
        get '/bureau_consultant/accounts/salary'
        assert_response :success
      end

      it 'displays the right requested_at date' do
        get '/bureau_consultant/accounts/salary'

        css_select("tr.wage").each do |wage|
          wage_id = wage.css('input[type="checkbox"]').first.attributes['value'].value
          date = Goxygene::Wage.find(wage_id).activity_report&.office_activity_report&.consultant_validation&.strftime('%d/%m/%Y')

          if date
            assert_equal date, wage.css('td.wage_requested_at').first.content
          end
        end
      end

      it 'displays a link to download the PDF' do
        get '/bureau_consultant/accounts/salary'

        css_select("tr.wage").each do |wage|
          wage_id = wage.css('input[type="checkbox"]').first.attributes['value'].value
          db_entry = Goxygene::Wage.find(wage_id)

          if db_entry.document
            assert_equal "\"/bureau_consultant/salaries/#{wage_id}/download.pdf\"",
                         wage.css('td.download a').first.attributes['href'].value.inspect
          end
        end
      end

      it 'displays wages within the default date range' do
        get '/bureau_consultant/accounts/salary'

        # check for the filter form values
        assert_ransack_filter :date_gteq, default_filter_date_lower_bound .strftime('%d/%m/%Y')
        assert_ransack_filter :date_lteq, default_filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.wage").each do |entry|
          entry_date = Date.new(entry.css("td.wage_year").first.content.to_i,
                                I18n.t("date.month_names").find_index(entry.css("td.wage_month").first.content.downcase))
          assert entry_date >= default_filter_date_lower_bound
          assert entry_date <= default_filter_date_higher_bound
        end
      end

      it 'can filter by creation date' do
        get '/bureau_consultant/accounts/salary',
            params: {
              q: {
                date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y'),
              }
            }

        # check for the filter form values
        assert_ransack_filter :date_gteq, filter_date_lower_bound .strftime('%d/%m/%Y')
        assert_ransack_filter :date_lteq, filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        css_select("tr.wage").each do |entry|
          entry_date = Date.new(entry.css("td.wage_year").first.content.to_i,
                                I18n.t("date.month_names").find_index(entry.css("td.wage_month").first.content.downcase))
          assert entry_date >= filter_date_lower_bound
          assert entry_date <= filter_date_higher_bound
        end
      end

      it 'sorts asc by year' do
        get '/bureau_consultant/accounts/salary',
            params: {
              q: {
                s: 'year asc',
                date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y')
              }
            }

        assert_tabledata_order(selector: 'tr.wage',
                               field: 'wage_year') { |entry, previous|

          previous.content.to_i <= entry.content.to_i

        }
      end

      it 'sorts desc by year' do
        get '/bureau_consultant/accounts/salary',
            params: {
              q: {
                s: 'year desc',
                date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y')
              }
            }

        assert_tabledata_order(selector: 'tr.wage',
                               field: 'wage_year') { |entry, previous|

          previous.content.to_i >= entry.content.to_i

        }
      end

      it 'sorts asc by month' do
        get '/bureau_consultant/accounts/salary',
            params: {
              q: {
                s: 'month asc',
                date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y')
              }
            }

        assert_tabledata_order(selector: 'tr.wage',
                               field: 'wage_month') { |entry, previous|

          I18n.t("date.month_names").find_index(previous.content.downcase) <= I18n.t("date.month_names").find_index(entry.content.downcase)

        }
      end

      it 'sorts desc by month' do
        get '/bureau_consultant/accounts/salary',
            params: {
              q: {
                s: 'month desc',
                date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y')
              }
            }

        assert_tabledata_order(selector: 'tr.wage',
                               field: 'wage_month') { |entry, previous|

          I18n.t("date.month_names").find_index(previous.content.downcase) >= I18n.t("date.month_names").find_index(entry.content.downcase)

        }
      end

      it 'sorts asc by hours' do
        get '/bureau_consultant/accounts/salary',
            params: {
              q: {
                s: 'hours asc',
                date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y')
              }
            }

        assert_tabledata_order(selector: 'tr.wage',
                               field: 'wage_hours') { |entry, previous|

          previous.content.to_f <= entry.content.to_f

        }
      end

      it 'sorts desc by hours' do
        get '/bureau_consultant/accounts/salary',
            params: {
              q: {
                s: 'hours desc',
                date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y')
              }
            }

        assert_tabledata_order(selector: 'tr.wage',
                               field: 'wage_hours') { |entry, previous|

          previous.content.to_f >= entry.content.to_f

        }
      end

      it 'sorts asc by gross wage' do
        get '/bureau_consultant/accounts/salary',
            params: {
              q: {
                s: 'gross_wage asc',
                date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y')
              }
            }

        assert_tabledata_order(selector: 'tr.wage',
                               field: 'wage_gross') { |entry, previous|

          previous.content.gsub(' ', '').gsub(',', '.').to_f <= entry.content.gsub(' ', '').gsub(',', '.').to_f

        }
      end

      it 'sorts desc by gross wage' do
        get '/bureau_consultant/accounts/salary',
            params: {
              q: {
                s: 'gross_wage desc',
                date_gteq: filter_date_lower_bound.strftime('%d/%m/%Y'),
                date_lteq: filter_date_higher_bound.strftime('%d/%m/%Y')
              }
            }

        assert_tabledata_order(selector: 'tr.wage',
                               field: 'wage_gross') { |entry, previous|

          previous.content.gsub(' ', '').gsub(',', '.').to_f >= entry.content.gsub(' ', '').gsub(',', '.').to_f

        }
      end
    end
  end

  describe 'not authenticated' do
    describe 'on the pending_costs page' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/accounts/pending_costs'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end

    describe 'on the salary page' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/accounts/salary'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end
  end
end

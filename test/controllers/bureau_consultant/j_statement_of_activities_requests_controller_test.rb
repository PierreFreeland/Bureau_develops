require 'test_helper'

describe 'BureauConsultant::StatementOfActivitiesRequestsController' do
  describe 'authenticated as a consultant' do

    let(:consultant)  { Goxygene::Consultant.find 9392 }

    before { sign_in cas_authentications(:jackie_denesik) }

    OfficeActivityReportIds = %w{
      169254 167675
      163948 163475 163474 159925 156537 156033 153224 151278 149684 147738 147079 144238 142410
      141010 140381 137820 136941 134588 133139 131668 131660 128242 128238 126698 124588 122486
      122243 120589 119376 117864 116416 114080 113353 112135 110754 109466 108385 107137 105491
      104364 102606 101500 99899 98653 98352 96000 95621 93621 93397 91306 91288 90429 90427
      87126 87119 85297 84035 83077 81836 80834 79366 78715 76691 75487 74559 73484 71919 71535
      71409 70219 67860 66905 66239
    }

    OfficeActivityReportIds = OfficeActivityReportIds.shuffle[0..5] unless ENV['ALL']

    describe 'on the history show action' do
      OfficeActivityReportIds.each do |office_activity_report_id|
        it "renders the report #{office_activity_report_id}" do
          get "/bureau_consultant/statement_of_activities_requests/history/#{office_activity_report_id}.pdf"
          assert_response :success
        end
      end
    end

    describe 'on a mobile' do
      describe 'on the history page' do

        it 'displays the statement of activities history page' do
          get '/m/bureau_consultant/statement_of_activities_requests/history'
          assert_response :success
        end

        it 'includes some lines' do
          get '/m/bureau_consultant/statement_of_activities_requests/history'
          assert_select 'div.data-row-wrapper div.data-row'
        end

        it 'displays the SOAR status' do
          get '/m/bureau_consultant/statement_of_activities_requests/history'

          assert_select 'div.data-row-wrapper div.data-row span.statement_of_activities_request_status',
                        "Validée"
        end

      end

    end

    describe 'on the history page' do

      let(:default_filter_date_lower_bound)  { 1.year.ago.beginning_of_year.to_date }
      let(:default_filter_date_higher_bound) { Date.current.end_of_year + 6.months  }
      let(:filter_date_lower_bound)          { 2.year.ago.beginning_of_year.to_date }
      let(:filter_date_higher_bound)         { 6.months.ago.to_date                 }

      it 'displays the statement of activities history page' do
        get '/bureau_consultant/statement_of_activities_requests/history'
        assert_response :success
      end

      it 'includes some lines' do
        get '/bureau_consultant/statement_of_activities_requests/history'
        assert_select 'table.soar tr.statement_of_activities_request'
      end

      it 'displays the SOAR status' do
        get '/bureau_consultant/statement_of_activities_requests/history'

        assert_select 'table.soar tr.statement_of_activities_request td.statement_of_activities_request_status',
                      "Validée"
      end

      it 'displays SOAs within the default date range' do
        get '/bureau_consultant/statement_of_activities_requests/history'

        # check for the filter form values
        assert_ransack_filter :date_without_day_gteq, default_filter_date_lower_bound .strftime('%m/%Y')
        assert_ransack_filter :date_without_day_lteq, default_filter_date_higher_bound.strftime('%m/%Y')

        # check if each entry is within the date range
        css_select("tr.statement_of_activities_request").each do |entry|
          entry_date = Date.new(entry.css("td.statement_of_activities_request_year").first.content.to_i,
                                I18n.t("date.month_names").find_index(entry.css("td.statement_of_activities_request_month").first.content.downcase))
          assert entry_date >= default_filter_date_lower_bound
          assert entry_date <= default_filter_date_higher_bound
        end
      end

      it 'can filter by creation date' do
        get '/bureau_consultant/statement_of_activities_requests/history',
            params: {
              q: {
                date_without_day_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_without_day_lteq: filter_date_higher_bound.strftime('%m/%Y'),
              }
            }

        # check for the filter form values
        assert_ransack_filter :date_without_day_gteq, filter_date_lower_bound .strftime('%m/%Y')
        assert_ransack_filter :date_without_day_lteq, filter_date_higher_bound.strftime('%m/%Y')

        # check if each entry is within the date range
        css_select("tr.statement_of_activities_request").each do |entry|
          entry_date = Date.new(entry.css("td.statement_of_activities_request_year").first.content.to_i,
                                I18n.t("date.month_names").find_index(entry.css("td.statement_of_activities_request_month").first.content.downcase))
          assert entry_date >= filter_date_lower_bound
          assert entry_date <= filter_date_higher_bound
        end
      end

      it 'sorts asc by year' do
        get '/bureau_consultant/statement_of_activities_requests/history',
            params: {
              q: {
                s: 'year asc',
                date_without_day_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_without_day_lteq: filter_date_higher_bound.strftime('%m/%Y')
              }
            }

        assert_tabledata_order(selector: 'tr.statement_of_activities_request',
                               field: 'statement_of_activities_request_year') { |entry, previous|

          previous.content.to_i <= entry.content.to_i

        }
      end

      it 'sorts desc by year' do
        get '/bureau_consultant/statement_of_activities_requests/history',
            params: {
              q: {
                s: 'year desc',
                date_without_day_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_without_day_lteq: filter_date_higher_bound.strftime('%m/%Y')
              }
            }

        assert_tabledata_order(selector: 'tr.statement_of_activities_request',
                               field: 'statement_of_activities_request_year') { |entry, previous|

          previous.content.to_i >= entry.content.to_i

        }
      end

      it 'sorts asc by month' do
        get '/bureau_consultant/statement_of_activities_requests/history',
            params: {
              q: {
                s: 'month asc',
                date_without_day_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_without_day_lteq: filter_date_higher_bound.strftime('%m/%Y')
              }
            }

        assert_tabledata_order(selector: 'tr.statement_of_activities_request',
                               field: 'statement_of_activities_request_month') { |entry, previous|

          I18n.t("date.month_names").find_index(previous.content.downcase) <= I18n.t("date.month_names").find_index(entry.content.downcase)

        }
      end

      it 'sorts desc by month' do
        get '/bureau_consultant/statement_of_activities_requests/history',
            params: {
              q: {
                s: 'month desc',
                date_without_day_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_without_day_lteq: filter_date_higher_bound.strftime('%m/%Y')
              }
            }

        assert_tabledata_order(selector: 'tr.statement_of_activities_request',
                               field: 'statement_of_activities_request_month') { |entry, previous|

          I18n.t("date.month_names").find_index(previous.content.downcase) >= I18n.t("date.month_names").find_index(entry.content.downcase)

        }
      end

    end

    describe 'on the export page' do
      let(:workbook) { RubyXL::Parser.parse_buffer(response.body) }

      before do
        get '/bureau_consultant/statement_of_activities_requests/history/export.xlsx',
            params: {
              q: {
                id_in: consultant.office_activity_report_ids.sort,
                date_without_day_gteq: 10.years.ago.strftime('%m/%Y'),
                date_without_day_lteq: 10.years.from_now.strftime('%m/%Y')
              }
            }
      end

      it 'responds with success' do
        assert_response :success
      end

      it 'translates the status' do
        assert_equal "Demande en cours de saisie", workbook[0][1][9].value
      end

      it 'does not format the number of days' do
        assert workbook[0][1][2].value.is_a?(Float) || workbook[0][1][2].value.is_a?(Integer)
      end

      it 'does not format the number of hours' do
        assert workbook[0][1][3].value.is_a?(Float) || workbook[0][1][3].value.is_a?(Integer)
      end

      it 'does not format the gross wage' do
        assert workbook[0][1][4].value.is_a?(Float) || workbook[0][1][6].value.is_a?(Integer)
      end

      it 'does not format the amount of expenses' do
        assert workbook[0][1][5].value.is_a?(Float) || workbook[0][1][7].value.is_a?(Integer)
      end

      it 'does not format the amount of KMs' do
        assert workbook[0][1][6].value.is_a?(Float) || workbook[0][1][8].value.is_a?(Integer)
      end

    end
  end

  describe 'not authenticated' do
    describe 'on the history page' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/statement_of_activities_requests/history'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end
  end
end

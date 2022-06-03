require 'test_helper'

describe BureauConsultant::StatementOfOperatingExpensesController do
  describe 'authenticated as a consultant' do

    let(:consultant)  { Goxygene::Consultant.find 9392 }

    before { sign_in cas_authentications(:jackie_denesik) }

    StatementOfOperatingExpensesRequestIds = %w{
      28032 28293 28743 29442 29819 30247 30539 31211 31664 31975 32726 33724 34200 34832 35135
      35140 36324 36732 37637 37638 37686 38885 39253 39269 39971 40766 41213 41381 42384 42495
      43045 43731 44164 44924 45340 46113 46587 47037 47654 48131 48622 49258 49849 50366 52260
      52275 52276 52278 53157 54605 54611 54628 55966 55967 56558 57147 58016 58365 59315 60187
      60876 60944 62013 62261 63591 63602 64377 65553 65554 66828 68391 68405 68589
    }

    StatementOfOperatingExpensesRequestIds = StatementOfOperatingExpensesRequestIds.shuffle[0..5] unless ENV['ALL']

    describe 'on mobile' do
      describe 'on the history action' do
        it 'renders the page' do
          get '/m/bureau_consultant/statement_of_operating_expenses_requests/history'

          assert_response :success
        end
      end
    end

    describe 'on the history action' do
      it 'renders the page' do
        get '/bureau_consultant/statement_of_operating_expenses_requests/history'

        assert_response :success
      end

      it 'includes the right state' do
        get '/bureau_consultant/statement_of_operating_expenses_requests/history'

        assert_select 'tr.office_operating_expense td.state', 'Demande en cours de saisie'
      end
    end

    describe 'on the export page' do
      let(:workbook) { RubyXL::Parser.parse_buffer(response.body) }

      before do
        get '/bureau_consultant/statement_of_operating_expenses_requests/history/export.xlsx',
            params: {
              q: {
                id_in: consultant.office_operating_expense_ids,
                date_without_day_gteq: 10.years.ago.strftime('%m/%Y'),
                date_without_day_lteq: 10.years.from_now.strftime('%m/%Y')
              }
            }
      end

      it 'responds with success' do
        assert_response :success
      end

      it 'translates the status' do
        assert_equal "Demande en cours de saisie", workbook[0][1][5].value
      end

      it 'does not format the amount of expenses without taxes' do
        assert workbook[0][1][2].value.is_a?(Float) || workbook[0][1][2].value.is_a?(Integer)
      end

      it 'does not format the amount of taxes' do
        assert workbook[0][1][3].value.is_a?(Float) || workbook[0][1][3].value.is_a?(Integer)
      end

      it 'does not format the amount of expenses with taxes' do
        assert workbook[0][1][4].value.is_a?(Float) || workbook[0][1][4].value.is_a?(Integer)
      end

    end

    describe 'on the history show action' do
      StatementOfOperatingExpensesRequestIds.each do |statement_of_operating_expenses_id|
        it "renders the statement of operating expenses request #{statement_of_operating_expenses_id}" do
          consultant = Goxygene::OfficeOperatingExpense.find(statement_of_operating_expenses_id).consultant

          sign_in CasAuthentication.find_by(cas_user_type: 'Goxygene::Consultant', cas_user_id: consultant)

          get "/bureau_consultant/statement_of_operating_expenses_requests/history/#{statement_of_operating_expenses_id}.pdf"

          assert_response :success
        end
      end
    end

  end

  describe 'not authenticated' do

    describe 'on the history action' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/statement_of_operating_expenses_requests/history'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end

  end
end

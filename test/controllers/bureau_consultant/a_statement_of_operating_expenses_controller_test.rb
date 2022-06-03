require 'test_helper'

describe 'BureauConsultant::StatementOfOperatingExpensesController' do
  describe 'authenticated as a consultant' do

    let(:consultant)  { Goxygene::Consultant.find 9392                        }
    let(:current_soo) { consultant.office_operating_expenses.in_edition.first }
    let(:comment)     { FFaker::Lorem.words(5).join(' ')                      }

    let(:balances) { OpenStruct.new id: consultant.id, cash: 9999.0, activity: 0.0, invoicing: 0.0 }

    let(:last_soo_from_current) do
      consultant.office_operating_expenses.find_by(
        year:  current_soo.year,
        month: current_soo.month
      )
    end

    let(:create_fresh_soo) do
      consultant.office_operating_expenses.in_edition.destroy_all
      consultant.office_operating_expenses.create!(
        year:  1.month.ago.year,
        month: 1.month.ago.month,
        created_by: cas_authentications(:jackie_denesik).cas_user.id,
        updated_by: cas_authentications(:jackie_denesik).cas_user.id
      )
    end

    let(:created_lines) do
      1.upto(50).collect do
        create_fresh_soo.office_operating_expense_lines.create!(
          expense_type:      Goxygene::ExpenseType.for_expenses.shuffle.first,
          vat_rate:          Goxygene::Vat.active.shuffle.first,
          total_with_taxes:  1 + rand(100),
          label:             FFaker::Lorem.words(5).join(' '),
          date:              current_soo.date + (rand 25).days,
          created_by:        cas_authentications(:jackie_denesik).cas_user.id,
          updated_by:        cas_authentications(:jackie_denesik).cas_user.id
        )
      end
    end

    let(:date) { consultant.allowed_statement_of_operating_expenses_request_dates.first }

    before { sign_in cas_authentications(:jackie_denesik) }

    StatementOfOperatingExpensesIds = %w{
      25304 25721 26719 26720 27249 27522 28439 28638 28878 29189 29695 30427 30879 31567 31652
      32273 32933 33168 34139 34140 35300 35302 35737 36350 36523 37008 37389 37733 38389 38674
      39139 39729 40319 40843 41343 41991 42448 42778 43442 43865 44485 44896 45528 45964 47645
      47646 47647 48497 48501 49932 49934 51237 51238 51887 52285 52829 53282 54022 54425 55364
      55975 56474 56802 57753 58330 59633 59634 60090 60535 61271 62759 62770
    }

    StatementOfOperatingExpensesIds = StatementOfOperatingExpensesIds.shuffle[0..5] unless ENV['ALL']

    describe 'on mobile' do
      describe 'on the history action' do
        it 'renders the page' do
          get '/m/bureau_consultant/statement_of_operating_expenses/history'

          assert_response :success
        end
      end
    end

    describe 'on the history show action' do
      StatementOfOperatingExpensesIds.each do |statement_of_expenses_id|
        it "renders the statement of operating expenses request #{statement_of_expenses_id}" do
          consultant = Goxygene::OperatingExpense.find(statement_of_expenses_id).consultant

          sign_in CasAuthentication.find_by(cas_user_type: 'Goxygene::Consultant', cas_user_id: consultant)

          get "/bureau_consultant/statement_of_operating_expenses/history/#{statement_of_expenses_id}.pdf"

          assert_response :success
        end
      end
    end

    describe 'when the consultant has expenses reimbursed' do
      describe 'on the synthesis action' do
        before { created_lines }

        describe 'when the SOO is in edition' do
          it 'renders the page' do
            get '/bureau_consultant/statement_of_operating_expenses/synthesis'

            assert_response :success
          end
        end

        describe 'when there is no SOO in edition' do
          before { current_soo.submit! }

          it 'redirects to the new action' do
            get '/bureau_consultant/statement_of_operating_expenses/synthesis'

            assert_redirected_to '/bureau_consultant/statement_of_operating_expenses/new'
          end
        end
      end

      describe 'on the submit action' do
        before do
          created_lines

          Rails.cache.clear
          Accountancy = Minitest::Mock.new
          Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
        end

        def put_submit_soo(attrs = {})
          put '/bureau_consultant/statement_of_operating_expenses/current/submit', params: {
            statement_of_operating_expenses_request: {
              consultant_comment: comment
            }.merge(attrs).compact
          }
        end

        describe 'when the SOO is in edition' do
          it 'updates the soo status' do
            put_submit_soo

            assert_equal 'office_validated', last_soo_from_current.operating_expenses_status
          end

          it 'stores the provided comment' do
            put_submit_soo

            assert_equal comment, last_soo_from_current.consultant_comment
          end

          it 'can accept an empty comment' do
            put_submit_soo consultant_comment: ''

            assert_response :success
            assert last_soo_from_current.consultant_comment.blank?
          end

          it 'does not create nor delete soo' do
            assert_no_difference 'Goxygene::OfficeOperatingExpense.count' do
              put_submit_soo
            end
          end

          it 'reloads cumuls for the consultant' do
            put_submit_soo

            assert_mock Accountancy
          end

          it 'sets the consultant_validation timestamp' do
            put_submit_soo

            assert_not_nil last_soo_from_current.consultant_validation
          end
        end

        describe 'when there is no SOO in edition' do
          before { current_soo.submit! }

          it 'redirects to the new action' do
            put_submit_soo

            assert_redirected_to '/bureau_consultant/statement_of_operating_expenses/new'
          end
        end


      end

      describe 'on the destroy action' do
        it 'destroys the SOO' do
          assert_difference 'Goxygene::OfficeOperatingExpense.count', -1 do
            delete '/bureau_consultant/statement_of_operating_expenses/current'
          end
        end

        it 'redirects to the soo history page' do
          delete '/bureau_consultant/statement_of_operating_expenses/current'
          assert_redirected_to '/bureau_consultant/statement_of_operating_expenses_requests/history'
        end
      end

      describe 'on the create action' do

        def post_create_soo
          post '/bureau_consultant/statement_of_operating_expenses', params: {
            statement_of_operating_expenses_request: {
              date: date.strftime('%m/%Y')
            }
          }
        end

        describe 'when a SOO is in edition' do
          before { created_lines }

          it 'does not create a new SOO' do
            assert_no_difference 'Goxygene::OfficeOperatingExpense.count' do
              post_create_soo
            end
          end

          it 'redirects to the SOO' do
            post_create_soo

            assert_redirected_to '/bureau_consultant/statement_of_operating_expenses/current'
          end
        end

        describe 'when no SOO is curently in edition' do
          let(:last_soo) { Goxygene::OfficeOperatingExpense.last }

          before { current_soo.submit! }

          it 'creates the SOO' do
            assert_difference 'Goxygene::OfficeOperatingExpense.count' do
              post_create_soo
            end
          end

          it 'sets the right date' do
            post_create_soo

            assert_equal date.year,  last_soo.year
            assert_equal date.month, last_soo.month
          end

          it 'sets the right created_by' do
            post_create_soo

            assert_equal consultant.individual_id, last_soo.created_by
          end

          it 'sets the right updated_by' do
            post_create_soo

            assert_equal consultant.individual_id, last_soo.updated_by
          end


          it 'redirects to the SOO' do
            post_create_soo

            assert_redirected_to '/bureau_consultant/statement_of_operating_expenses/current'
          end
        end
      end

      describe 'on the new action' do
        describe 'when a DF is in edition' do
          before { created_lines }

          it 'redirects to the SOO' do
            get '/bureau_consultant/statement_of_operating_expenses/new'

            assert_redirected_to '/bureau_consultant/statement_of_operating_expenses/current'
          end
        end

        describe 'when the consultant can create a new DF' do
          before do
            current_soo.submit!

            get '/bureau_consultant/statement_of_operating_expenses/new'
          end

          it 'renders the page' do
            assert_response :success
          end

          it 'lists the months available for a new DF' do
            0.upto(11).each do |n|
              date = n.months.ago.beginning_of_month.to_date.strftime
              assert_select "option[value=\"#{date}\"]"
            end
          end
        end

        describe 'when the consultant has already submit its last DF' do
          before do
            current_soo.update! year: Date.today.year, month: Date.today.month
            current_soo.submit!

            get '/bureau_consultant/statement_of_operating_expenses/new'
          end

          it 'does not render a list of months' do
            assert_select 'option', { count: 0 }
          end

          it 'renders the page' do
            assert_response :success
          end
        end
      end

      describe 'on the show action' do
        describe 'when a DF is in edition' do
          before do
            created_lines
            get '/bureau_consultant/statement_of_operating_expenses/current'
          end

          it 'renders the page' do
            assert_response :success
          end

          it 'lists the expense types' do
            assert_equal Goxygene::ExpenseType.where("for_expenses AND NOT is_kilometers").count,
                         css_select('select#office_operating_expense_line_expense_type_id option').count
          end

          it 'includes the capital asset attribute' do
            assert_select 'option[data-capital-asset="true"][value="1"]', 'Bureau (fournitures)'
          end

          it 'lists the vat rates' do
            assert_select 'select#office_operating_expense_line_vat_id option', Goxygene::Vat.active.for_bureau.count

            css_select('select#office_operating_expense_line_vat_id option').each do |vat_value|
              assert Goxygene::Vat.active.for_bureau.find(vat_value.attributes['value'].value)
            end
          end

          describe 'when a line is being edited' do
            it 'renders the page' do
              get '/bureau_consultant/statement_of_operating_expenses/current', params: { line_id: created_lines.last.id }

              assert_response :success
            end
          end
        end

        describe 'when there is no DF in edition' do
          before { consultant.office_operating_expenses.in_edition.destroy_all }

          it 'redirects to the new action' do
            get '/bureau_consultant/statement_of_operating_expenses/current'

            assert_redirected_to '/bureau_consultant/statement_of_operating_expenses/new'
          end
        end
      end

      describe 'on the index action' do
        describe 'when a SOO is in edition' do
          before { created_lines }

          it 'redirects to the SOO' do
            get '/bureau_consultant/statement_of_operating_expenses'

            assert_redirected_to '/bureau_consultant/statement_of_operating_expenses/current'
          end
        end

        describe 'when there is no SOO in edition' do
          before { consultant.office_operating_expenses.in_edition.destroy_all }

          it 'redirects to the new action' do
            get '/bureau_consultant/statement_of_operating_expenses'

            assert_redirected_to '/bureau_consultant/statement_of_operating_expenses/new'
          end
        end
      end

      describe 'on the history action' do
        it 'renders the page' do
          get '/bureau_consultant/statement_of_operating_expenses/history'

          assert_response :success
        end
      end

      describe 'on the export page' do
        let(:workbook) { RubyXL::Parser.parse_buffer(response.body) }

        before do
          get '/bureau_consultant/statement_of_operating_expenses/history/export.xlsx',
              params: {
                q: {
                  id_in: consultant.operating_expense_ids,
                  date_without_day_gteq: 10.years.ago.strftime('%m/%Y'),
                  date_without_day_lteq: 10.years.from_now.strftime('%m/%Y')
                }
              }
        end

        it 'responds with success' do
          assert_response :success
        end

        it 'translates the status' do
          assert_equal "Validée", workbook[0][1][5].value
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
    end

    describe 'when the consultant does not have expenses reimbursed' do
      before { consultant.update! granted_expenses: false }

      describe 'on the create action' do

        def post_create_soo
          post '/bureau_consultant/statement_of_operating_expenses', params: {
            statement_of_operating_expenses_request: {
              date: date.strftime('%m/%Y')
            }
          }
        end

        it 'does not create a new SOO' do
          assert_no_difference 'Goxygene::OfficeOperatingExpense.count' do
            post_create_soo
          end

        end

        it 'redirects to the home page' do
          post_create_soo

          assert_redirected_to '/bureau_consultant/'
        end

      end

      describe 'on the new action' do
        before { current_soo.submit! }

        it 'redirects to the home page' do
          get '/bureau_consultant/statement_of_operating_expenses/new'

          assert_redirected_to '/bureau_consultant/'
        end
      end

      describe 'on the show action' do
        before { consultant.office_operating_expenses.in_edition.destroy_all }

        it 'redirects to the home page' do
          get '/bureau_consultant/statement_of_operating_expenses/current'

          assert_redirected_to '/bureau_consultant/'
        end
      end

      describe 'on the index action' do
        before { consultant.office_operating_expenses.in_edition.destroy_all }

        it 'redirects to the new action' do
          get '/bureau_consultant/statement_of_operating_expenses'

          assert_redirected_to '/bureau_consultant/'
        end
      end

      describe 'on the history action' do
        it 'redirects to the new action' do
          get '/bureau_consultant/statement_of_operating_expenses/history'

          assert_redirected_to '/bureau_consultant/'
        end
      end
    end

  end

  describe 'not authenticated' do
    describe 'on the index action' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/statement_of_operating_expenses'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end

    describe 'on the new action' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/statement_of_operating_expenses/new'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end

    describe 'on the history action' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/statement_of_operating_expenses/history'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end

    describe 'on the show action' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/statement_of_operating_expenses/current'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end
  end
end

require 'test_helper'

describe 'BureauConsultant::StatementOfActivitiesController' do
  describe 'authenticated as a consultant' do

    ConsultantId      = 9392

    ActivityReportIds = %w{
      60203 60871 63325 63326 64362 64807 66131 67010 67891 68382 69632 71250 72062 73177 74129
      75361 76200 77380 79089 79090 82116 82117 84162 84163 84836 85865 86848 87763 89375 90316
      90712 92311 93304 94882 96012 97632 98647 99689 100983 102155 103226 104607 106184 107511
      108855 110007 111472 113132 113587 115658 117035 118759 120212 121619 123011 124278 125038
      127022 128208 130084 131518 132875 134835 136374 138523 139555 141385 143055 143969 146483
      149928 149930 153585 153586 155131
    }

    ActivityReportIds = ActivityReportIds.shuffle[0..5] unless ENV['ALL']

    let(:consultant)  { Goxygene::Consultant.find ConsultantId             }
    let(:current_soa) { consultant.current_statement_of_activities_request }


    let(:activity_type)     { Goxygene::ActivityType.mission_or_development.active.shuffle.first }
    let(:expense_type)      { Goxygene::ExpenseType.for_activities.has_vat.shuffle.first         }
    let(:time_span)         { [0.25, 0.5, 0.75, 1].shuffle.first                                 }
    let(:label)             { FFaker::Lorem.words(5).join(' ')                                   }
    let(:expense_label)     { FFaker::Lorem.words(5).join(' ')                                   }
    let(:activity_date)     { current_soa.date + 5.days                                          }
    let(:expense_with_vat)  { rand 100                                                           }
    let(:comment)           { FFaker::Lorem.words(5).join(' ')                                   }
    let(:gross_wage)        { 1500 + rand(1234)                                                  }

    let(:distance_expense_type) { Goxygene::ExpenseType.for_activities.km_type_ids.first }

    let(:balances)          { OpenStruct.new id: consultant.id, cash: 99999.0, activity: 99999, invoicing: 0.0 }
    let(:negative_balances) { OpenStruct.new id: consultant.id, cash: -9999.0, activity: 0.0,   invoicing: 0.0 }

    let(:existing_entry) do
      current_soa.office_activity_report_lines.create!(
        activity_type: Goxygene::ActivityType.mission_or_development.active.shuffle.first,
        time_span:     0.75,
        label:         FFaker::Lorem.words(5).join(' '),
        date:          activity_date,
        created_by:    cas_authentications(:jackie_denesik).cas_user.id,
        updated_by:    cas_authentications(:jackie_denesik).cas_user.id,
      )
    end

    let(:existing_expense) do
      existing_entry.office_activity_report_expenses.create!(
        expense_type:     Goxygene::ExpenseType.for_activities.without_vehicle.shuffle.first,
        label:            expense_label,
        total:            1 + rand(100),
        created_by:       cas_authentications(:jackie_denesik).cas_user.id,
        updated_by:       cas_authentications(:jackie_denesik).cas_user.id
      )
    end

    let(:existing_distance_expense) do
      existing_entry.office_activity_report_expenses.create!(
        expense_type_id:  distance_expense_type,
        label:            expense_label,
        kilometers:       rand(123),
        created_by:       cas_authentications(:jackie_denesik).cas_user.id,
        updated_by:       cas_authentications(:jackie_denesik).cas_user.id
      )
    end

    let(:create_fresh_soa) do
      consultant.office_activity_reports.in_edition.destroy_all
      consultant.office_activity_reports.create!(
        year:  consultant.first_possible_statement_of_activities_request_month.year,
        month: consultant.first_possible_statement_of_activities_request_month.month,
        created_by: cas_authentications(:jackie_denesik).cas_user.id,
        updated_by: cas_authentications(:jackie_denesik).cas_user.id
      )
    end

    let(:created_activities) do
      1.upto(20).collect do
        current_soa.office_activity_report_lines.create(
          activity_type: Goxygene::ActivityType.mission_or_development.active.shuffle.first,
          time_span:     [0.25, 0.5, 0.75, 1].shuffle.first,
          label:         FFaker::Lorem.words(5).join(' '),
          date:          current_soa.date + (Random.rand 30).days,
          created_by:    cas_authentications(:jackie_denesik).cas_user.id,
          updated_by:    cas_authentications(:jackie_denesik).cas_user.id
        )
      end.select(&:persisted?)
    end

    let(:created_activities_with_expenses) do
      created_activities.each do |activity|
        1.upto(rand 10).each do
          activity.office_activity_report_expenses.create!(
            expense_type:     Goxygene::ExpenseType.for_activities.shuffle.first,
            label:            FFaker::Lorem.words(5).join(' '),
            total:            1 + rand(100),
            created_by:       cas_authentications(:jackie_denesik).cas_user.id,
            updated_by:       cas_authentications(:jackie_denesik).cas_user.id
          )
        end
      end
    end

    before { sign_in cas_authentications(:jackie_denesik) }

    describe 'on a mobile' do
      describe 'on the new action' do
        before do
          create_fresh_soa
        end

        describe 'when activities have been validated' do
          before do
            current_soa.reload.update! activity_report_status:         :pending,
                                       activity_report_expense_status: :office_editing
          end

          it 'redirects to the expenses edition page' do
            get '/m/bureau_consultant/statement_of_activities/new'

            assert_redirected_to '/m/bureau_consultant/statement_of_activities/manage_mission'
          end
        end

        describe 'when the SOA has no lines (empty)' do
          before do
            current_soa.office_activity_report_lines.destroy_all
          end

          it 'redirects to the first time new action' do
            get '/m/bureau_consultant/statement_of_activities/new'

            assert_redirected_to '/m/bureau_consultant/statement_of_activities/first_time_new'
          end
        end

        describe 'when SOA is in edition and already have some lines' do
          before { created_activities_with_expenses }

          it 'renders the page' do
            get '/m/bureau_consultant/statement_of_activities/new'

            assert_response :success
          end
        end

        describe 'when no statement of activities is currently in edition' do
          it 'redirects to the first time da action' do
            current_soa.destroy if current_soa

            get '/m/bureau_consultant/statement_of_activities/new'

            assert_redirected_to '/m/bureau_consultant/statement_of_activities/first_time_da'
          end
        end
      end

      describe 'on the first time da action' do
        describe 'when no statement of activities is currently in edition' do
          describe 'when a new statement of activities is possible' do
            before do
              consultant.office_activity_reports.in_edition.destroy_all

              Rails.cache.clear

              Accountancy = Minitest::Mock.new
              Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
            end

            it 'renders the page' do
              get '/m/bureau_consultant/statement_of_activities/first_time_da'
              assert_response :success
            end

            it 'displays a selection of available months' do
              get '/m/bureau_consultant/statement_of_activities/first_time_da'

              assert_select 'select#statement_of_activities_request_date'
              css_select('select#statement_of_activities_request_date option').each do |option|
                assert_equal consultant.first_possible_statement_of_activities_request_month, Date.parse(option['value'])
              end
            end
          end

          describe 'when a new statement of activities is not possible' do
            it 'redirects to the wait page'
          end
        end

        describe 'when a statement of activities is currently in edition' do
          it 'redirects to the new action' do
            # checks if the consultant has a statement of activities in edition
            assert !!current_soa

            get '/m/bureau_consultant/statement_of_activities/first_time_da'

            assert_redirected_to '/m/bureau_consultant/statement_of_activities/new'
          end
        end
      end

      describe 'on the manage mission action' do
        describe 'when the consultant can have expenses refunded' do
          before do
            created_activities_with_expenses

            get '/m/bureau_consultant/statement_of_activities/manage_mission'
          end

          it 'renders the page' do
            assert_response :success
          end

          it 'orders the expenses by item number' do
            css_select("div.activity").each do |activity|
              previous = nil

              activity.css("table.expenses td span.expense_item_number").each do |entry|
                if previous.nil?
                  previous = entry
                  next
                end

                assert entry.content.to_i > previous.content.to_i

                previous = entry
              end
            end
          end

          describe 'when the current SOA is not in expenses edition mode' do
            before do
              created_activities_with_expenses.last
              current_soa.reload.update! activity_report_expense_status: :office_validated
            end

            it 'redirects to synthesis_3_step' do
              get '/m/bureau_consultant/statement_of_activities/manage_mission'

              assert_redirected_to '/m/bureau_consultant/statement_of_activities/synthesis_3_step'
            end
          end
        end

        describe 'when the consultant does not have expenses refunded' do
          before do
            consultant.update! granted_expenses: false
            created_activities
          end

          it 'redirects to synthesis_3_step' do
            get '/m/bureau_consultant/statement_of_activities/manage_mission'

            assert_redirected_to '/m/bureau_consultant/statement_of_activities/synthesis_3_step'
          end
        end
      end

      describe 'on the mission expense action' do
        describe 'when the consultant can have expenses refunded' do
          before do
            create_fresh_soa
            created_activities_with_expenses
          end

          it 'renders the page' do
            get '/m/bureau_consultant/statement_of_activities/mission_expense'

            assert_response :success
          end

          describe 'when a SOA is over DSN office date' do
            before do
              current_soa.update_columns month: 10
              current_soa.reload
            end

            it 'renders the page' do
              get '/m/bureau_consultant/statement_of_activities/mission_expense'

              assert_response :success
            end

            it 'does not set the opened SOA as rejected' do
              soa_id = current_soa.id

              get '/m/bureau_consultant/statement_of_activities/mission_expense'

              assert_equal 'office_editing', consultant.office_activity_reports.find(soa_id).activity_report_status
            end
          end

          describe 'when the current SOA is not in expenses edition mode' do
            before do
              current_soa.reload.update! activity_report_expense_status: :office_validated
            end

            it 'redirects to synthesis_3_step' do
              get '/m/bureau_consultant/statement_of_activities/mission_expense'

              assert_redirected_to '/m/bureau_consultant/statement_of_activities/synthesis_3_step'
            end
          end
        end

        describe 'when the consultant does not have expenses refunded' do
          before do
            consultant.update! granted_expenses: false
            create_fresh_soa
            created_activities
          end

          it 'redirects to synthesis_3_step' do
            get '/m/bureau_consultant/statement_of_activities/mission_expense'

            assert_redirected_to '/m/bureau_consultant/statement_of_activities/synthesis_3_step'
          end
        end
      end


      describe 'on the manage mission expense action' do

        def get_manage_mission_expense(expense_id: nil, activity_id: nil)
          activity = created_activities_with_expenses.select {|a| a.office_activity_report_expenses.any? }.last
          expense  = activity.office_activity_report_expenses.last

          get '/m/bureau_consultant/statement_of_activities/manage_mission_expense', params: {
            activity_id: activity_id || activity.id,
            expense_id:  expense_id  || expense.id
          }
        end

        describe 'when the consultant can have expenses refunded' do
          it 'renders the page' do
            created_activities_with_expenses

            get_manage_mission_expense

            assert_response :success
          end

          describe 'when the current SOA has only activities validated' do
            before do
              created_activities_with_expenses.last
              current_soa.reload.update! activity_report_status: :office_validated,
                                         gross_wage: current_soa.standard_gross_wage
            end

            it 'renders the page' do
              get_manage_mission_expense

              assert_response :success
            end
          end

          describe 'when the current SOA is not in expenses edition mode' do
            before do
              created_activities_with_expenses.last
              current_soa.reload.update! activity_report_expense_status: :office_validated
            end

            it 'redirects to synthesis_3_step' do
              get_manage_mission_expense

              assert_redirected_to '/m/bureau_consultant/statement_of_activities/synthesis_3_step'
            end
          end
        end

        describe 'when the consultant does not have expenses refunded' do
          before do
            consultant.update! granted_expenses: false
            created_activities
          end

          it 'redirects to synthesis_3_step' do
            get_manage_mission_expense

            assert_redirected_to '/m/bureau_consultant/statement_of_activities/synthesis_3_step'
          end
        end
      end

      describe 'on the history page' do

        it 'displays the statement of activities history page' do
          get '/m/bureau_consultant/statement_of_activities/history'
          assert_response :success
        end

      end

    end

    describe 'on the history show action' do
      ActivityReportIds.each do |activity_report_id|
        it "renders the report #{activity_report_id}" do
          get "/bureau_consultant/statement_of_activities/history/#{activity_report_id}.pdf"
          assert_response :success
        end
      end
    end

    describe 'on the mission month select action' do
      it 'renders the page' do
        get '/bureau_consultant/statement_of_activities/mission_month_select'

        assert_response :success
      end
    end

    describe 'on the submit action' do
      before do
        # consultant.office_activity_reports.where(year: Date.current.year, month: Date.current.month).each &:destroy
        # create_fresh_soa
        Rails.cache.clear
        Accountancy = Minitest::Mock.new
        Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
      end

      describe 'with no activity' do

        def put_submit(attrs = {})
          put '/bureau_consultant/statement_of_activities/submit', params: {
            statement_of_activities_request: {
              date: Date.today.beginning_of_month.strftime,
              gross_wage: gross_wage,
              no_activity: 'true'
            }.merge(attrs)
          }
        end

        describe 'with a consultant with no expense refund' do
          before do
            consultant.office_activity_reports.in_edition.destroy_all
            consultant.update granted_expenses: false
          end

          it 'responds with success' do
            put_submit
            assert_response :success
          end

          it 'set the right status' do
            put_submit

            soa = Goxygene::OfficeActivityReport.last

            assert soa.no_activity
            assert_equal 'office_validated', soa.activity_report_status
            assert_equal 'office_validated', soa.activity_report_expense_status
            assert_equal gross_wage,         soa.gross_wage
          end

          it 'calls the Accountancy API' do
            put_submit
            assert_mock Accountancy
          end

          it 'creates a SOA in database' do
            assert_difference 'Goxygene::OfficeActivityReport.count' do
              put_submit
            end
          end

          it 'sets the consultant_validation timestamp' do
            put_submit

            soa = Goxygene::OfficeActivityReport.last

            assert ((Time.now.to_i - 10)..(Time.now.to_i + 10)).include? soa.reload.consultant_validation.to_i
          end
        end

        describe 'with a negative balance' do
          before do
            consultant.office_activity_reports.in_edition.destroy_all

            Accountancy = Minitest::Mock.new
            Accountancy.expect(:consultant_account_balances, negative_balances, [consultant.id, environment: "FREELAND", clear_cache: true])
          end


          it 'responds with a 422' do
            put_submit
            assert_response 422
          end

          it 'calls the Accountancy API' do
            put_submit
            assert_mock Accountancy
          end

          it 'does not create a SOA in database' do
            assert_no_difference 'Goxygene::OfficeActivityReport.count' do
              put_submit
            end
          end

        end

        describe 'with a positive balance' do
          before do
            consultant.office_activity_reports.in_edition.destroy_all
          end

          it 'responds with success' do
            put_submit
            assert_response :success
          end

          it 'set the right status' do
            put_submit

            soa = Goxygene::OfficeActivityReport.last

            assert soa.no_activity
            assert_equal 'office_validated', soa.activity_report_status
            assert_equal 'office_validated', soa.activity_report_expense_status
            assert_equal gross_wage,         soa.gross_wage
          end

          it 'calls the Accountancy API' do
            put_submit
            assert_mock Accountancy
          end

          it 'creates a SOA in database' do
            assert_difference 'Goxygene::OfficeActivityReport.count' do
              put_submit
            end
          end

          it 'sets the supplementary_gross_wage' do
            put_submit gross_wage: gross_wage + 1234

            soa = Goxygene::OfficeActivityReport.last

            assert_equal gross_wage + 1234, soa.gross_wage
            assert_equal gross_wage + 1234, soa.supplementary_gross_wage
            assert_equal 0,                 soa.standard_gross_wage
          end

          it 'sets the consultant_validation timestamp' do
            put_submit

            soa = Goxygene::OfficeActivityReport.last

            assert ((Time.now.to_i - 10)..(Time.now.to_i + 10)).include? soa.reload.consultant_validation.to_i
          end

        end

      end

      describe 'validating exp+act' do
        before do
          create_fresh_soa
          created_activities_with_expenses

          Rails.cache.clear
          Accountancy = Minitest::Mock.new
          Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
        end

        def put_submit(attrs = {})
          put '/bureau_consultant/statement_of_activities/submit', params: {
            office_activity_report: {
              consultant_comment: comment,
              gross_wage: gross_wage
            }.merge(attrs)
          }
        end

        it 'responds with success' do
          put_submit
          assert_response :success
        end

        it 'set the right status' do
          soa_id = current_soa.id

          put_submit

          soa = Goxygene::OfficeActivityReport.find(soa_id)

          assert_equal 'office_validated', soa.activity_report_status
          assert_equal 'office_validated', soa.activity_report_expense_status
          assert_equal gross_wage,         soa.gross_wage
          assert_equal comment,            soa.consultant_comment
        end

        it 'sets the supplementary_gross_wage' do
          soa_id = current_soa.id

          soa = Goxygene::OfficeActivityReport.find(soa_id)

          put_submit gross_wage: soa.standard_gross_wage + 1234

          soa.reload

          assert_equal soa.standard_gross_wage + 1234, soa.gross_wage
          assert_equal 1234,                           soa.supplementary_gross_wage
        end

        it 'sets the consultant_validation timestamp' do
          soa_id = current_soa.id

          put_submit

          soa = Goxygene::OfficeActivityReport.find(soa_id)

          assert ((Time.now.to_i - 10)..(Time.now.to_i + 10)).include? soa.reload.consultant_validation.to_i
        end
      end

      describe 'validating activities only' do
        before do
          create_fresh_soa
          created_activities
        end

        def put_submit(attrs = {})
          put '/bureau_consultant/statement_of_activities/submit', params: {
            activities_only: 'true',
            office_activity_report: {
              consultant_comment: comment,
              gross_wage: current_soa.standard_gross_wage
            }.merge(attrs)
          }
        end

        describe 'with a consultant with expenses reimbursed' do
          it 'responds with success' do
            put_submit
            assert_response :success
          end

          it 'set the right status' do
            soa_id = current_soa.id

            put_submit

            soa = Goxygene::OfficeActivityReport.find(soa_id)

            assert_equal 'office_validated',      soa.activity_report_status
            assert_equal 'office_editing',        soa.activity_report_expense_status
            assert_equal soa.standard_gross_wage, soa.gross_wage
            assert_equal comment,                 soa.consultant_comment
          end

          it 'calls the Accountancy API' do
            put_submit
            assert_mock Accountancy
          end

          it 'sets the consultant_validation timestamp' do
            soa_id = current_soa.id

            put_submit

            soa = Goxygene::OfficeActivityReport.find(soa_id)

            assert ((Time.now.to_i - 10)..(Time.now.to_i + 10)).include? soa.reload.consultant_validation.to_i
          end

          describe 'when submiting a gross_wage higher than authorized' do
            it 'responds with a 422' do
              put_submit gross_wage: 10_000_000

              assert_response 422
            end

            it 'responds with an error message' do
              put_submit gross_wage: 10_000_000

              assert_equal "Compte tenu de vos activités déclarées et de votre solde financier, votre salaire du mois doit être égal à votre salaire brut conventionnel",
                           JSON.parse(response.body)["errors"].first
            end

            it 'does not update the status' do
              soa_id = current_soa.id

              put_submit gross_wage: 10_000_000

              soa = Goxygene::OfficeActivityReport.find(soa_id)
              assert_equal 'office_editing', soa.activity_report_status
            end

            it 'does not update the gross_wage' do
              soa_id = current_soa.id

              put_submit gross_wage: 10_000_000

              soa = Goxygene::OfficeActivityReport.find(soa_id)
              assert_not_equal 10_000_000, soa.gross_wage
            end

            it 'calls the Accountancy API' do
              put_submit gross_wage: 10_000_000

              assert_mock Accountancy
            end
          end
        end

        describe 'with a consultant without expenses reimbursed' do
          before { consultant.update granted_expenses: false }

          it 'responds with success' do
            put_submit
            assert_response :success
          end

          it 'set the right status' do
            soa_id = current_soa.id

            put_submit

            soa = Goxygene::OfficeActivityReport.find(soa_id)

            assert_equal 'office_validated',      soa.activity_report_status
            assert_equal 'office_editing',        soa.activity_report_expense_status
            assert_equal soa.standard_gross_wage, soa.gross_wage
            assert_equal comment,                 soa.consultant_comment
          end

          it 'calls the Accountancy API' do
            put_submit
            assert_mock Accountancy
          end

          it 'sets the consultant_validation timestamp' do
            soa_id = current_soa.id

            put_submit

            soa = Goxygene::OfficeActivityReport.find(soa_id)

            assert ((Time.now.to_i - 10)..(Time.now.to_i + 10)).include? soa.reload.consultant_validation.to_i
          end
        end

      end

      describe 'validating expenses only' do
        before do
          create_fresh_soa
          created_activities_with_expenses
          current_soa.reload.update! activity_report_status: :office_validated,
                                     consultant_comment: comment,
                                     gross_wage: current_soa.standard_gross_wage
          current_soa.accept
        end

        def put_submit
          put '/bureau_consultant/statement_of_activities/submit', params: {
            office_activity_report: { foo: 'bar' }
          }
        end

        describe 'with a high gross_wage' do
          before do
            current_soa.reload.update_columns gross_wage: current_soa.standard_gross_wage + 5000,
                                              activity_report_status: :office_validated
          end

          it 'responds with success' do
            put_submit
            assert_response :success
          end

          it 'set the right status' do
            soa_id = current_soa.id

            put_submit

            soa = Goxygene::OfficeActivityReport.find(soa_id)

            assert_equal 'office_validated',      soa.activity_report_status
            assert_equal 'pending',               soa.activity_report_expense_status
            assert_equal comment,                 soa.consultant_comment
            assert_equal soa.standard_gross_wage + 5000, soa.gross_wage
          end
        end

        it 'responds with success' do
          put_submit
          assert_response :success
        end

        it 'set the right status' do
          soa_id = current_soa.id

          put_submit

          soa = Goxygene::OfficeActivityReport.find(soa_id)

          assert_equal 'itg_editing',           soa.activity_report_status
          assert_equal 'pending',          soa.activity_report_expense_status
          assert_equal soa.standard_gross_wage, soa.gross_wage
          assert_equal comment,                 soa.consultant_comment
        end

        it 'links each expense with their office counterpart' do
          soa_id = current_soa.id

          put_submit

          soa = Goxygene::OfficeActivityReport.find(soa_id)

          soa.activity_report.activity_report_lines.each do |line|
            line.activity_report_expenses.each do |expense|
              assert expense.office_activity_report_expense
            end
          end
        end

        it 'creates the expenses lines for the DA' do
          expenses_count = current_soa.office_activity_report_expenses.count

          assert_difference 'Goxygene::ActivityReportExpense.count', expenses_count do
            put_submit
          end
        end

        it 'sets the consultant_validation timestamp' do
          soa_id = current_soa.id

          put_submit

          soa = Goxygene::OfficeActivityReport.find(soa_id)

          assert ((Time.now.to_i - 10)..(Time.now.to_i + 10)).include? soa.reload.consultant_validation.to_i
        end

        it 'sets the DA expenses status' do
          soa_id = current_soa.id

          put_submit

          soa = Goxygene::OfficeActivityReport.find(soa_id)

          assert_equal 'pending', soa.activity_report.activity_report_expense_status
        end

        describe 'when the DA has been validated' do
          before do
            current_soa.activity_report.update! activity_report_status: 'completed'
          end

          it 'responds with success' do
            put_submit
            assert_response :success
          end

          it 'sets the DA expenses status' do
            soa_id = current_soa.id

            put_submit

            soa = Goxygene::OfficeActivityReport.find(soa_id)

            assert_equal 'pending', soa.activity_report.activity_report_expense_status
          end
        end
      end

      describe 'when automated acceptance is possible' do

        describe 'when c.activity_report' do

          before do
            consultant.update_columns activity_report: true
            create_fresh_soa
          end

          describe 'validating act+exp' do
            describe 'with no expenses' do
              let(:current_dda) { created_activities.first.office_activity_report.reload }
              let(:current_da)  { current_dda.activity_report                            }

              before do
                created_activities
              end

              def put_submit(attrs = {})
                put '/bureau_consultant/statement_of_activities/submit', params: {
                  office_activity_report: {
                    consultant_comment: nil,
                    gross_wage: gross_wage
                  }.merge(attrs)
                }
              end

              it 'does not create a DA' do
                assert_no_difference 'Goxygene::ActivityReport.count' do
                  put_submit
                end
              end

              it 'does not create a DA with all the lines' do
                assert_no_difference 'Goxygene::ActivityReportLine.count' do
                  put_submit
                end
              end

              it 'does not create any DA expenses' do
                assert_no_difference 'Goxygene::ActivityReportExpense.count' do
                  put_submit
                end
              end

              it 'sets the right status for the DDA' do
                put_submit

                assert_equal 'office_editing', current_dda.activity_report_status
                assert_equal 'office_editing', current_dda.activity_report_expense_status
              end

              it 'does not generate a new wage' do
                assert_no_difference 'Goxygene::Wage.count' do
                  put_submit
                end
              end
            end

            describe 'with some expenses' do
              let(:current_dda) { created_activities_with_expenses.first.office_activity_report.reload }
              let(:current_da)  { current_dda.activity_report                                          }

              before do
                created_activities_with_expenses
              end

              def put_submit(attrs = {})
                put '/bureau_consultant/statement_of_activities/submit', params: {
                  office_activity_report: {
                    consultant_comment: nil,
                    gross_wage: gross_wage
                  }.merge(attrs)
                }
              end

              it 'does not create a DA' do
                assert_no_difference 'Goxygene::ActivityReport.count' do
                  put_submit
                end
              end

              it 'does not create all the lines' do
                assert_no_difference 'Goxygene::ActivityReportLine.count' do
                  put_submit
                end
              end

              it 'does not creates all the expenses' do
                assert_no_difference 'Goxygene::ActivityReportExpense.count' do
                  put_submit
                end
              end

              it 'sets the right status for the DDA' do
                put_submit

                assert_equal 'office_editing', current_dda.activity_report_status
                assert_equal 'office_editing', current_dda.activity_report_expense_status
              end

              it 'does not generate a new wage' do
                assert_no_difference 'Goxygene::Wage.count' do
                  put_submit
                end
              end
            end
          end

          describe 'validating activites only' do
            let(:current_dda) { created_activities_with_expenses.first.office_activity_report.reload }
            let(:current_da)  { current_dda.activity_report                                          }

            before do
              created_activities_with_expenses
            end

            def put_submit(attrs = {})
              put '/bureau_consultant/statement_of_activities/submit', params: {
                activities_only: 'true',
                office_activity_report: {
                  consultant_comment: nil,
                  gross_wage: gross_wage
                }.merge(attrs)
              }
            end

            it 'does not create a DA' do
              assert_no_difference 'Goxygene::ActivityReport.count' do
                put_submit
              end
            end

            it 'does not create all the lines' do
              assert_no_difference 'Goxygene::ActivityReportLine.count' do
                put_submit
              end
            end

            it 'does not create any DA expenses' do
              assert_no_difference 'Goxygene::ActivityReportExpense.count' do
                put_submit
              end
            end

            it 'sets the right status for the DDA' do
              put_submit

              assert_equal 'office_editing', current_dda.activity_report_status
              assert_equal 'office_editing', current_dda.activity_report_expense_status
            end

            it 'does not generate a new wage' do
              assert_no_difference 'Goxygene::Wage.count' do
                put_submit
              end
            end
          end

        end

        describe 'when !c.activity_report' do

          before do
            create_fresh_soa
            Accountancy.expect(:accounting_entries__salary!, OpenStruct.new(:RefCompta => '12345'), [Hash])
          end

          describe 'validating act+ext' do
            describe 'with no expenses' do
              let(:current_dda) { created_activities.first.office_activity_report.reload }
              let(:current_da)  { current_dda.activity_report                            }

              before do
                created_activities

                Rails.cache.clear
                Accountancy = Minitest::Mock.new
                Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
                Accountancy.expect(:accounting_entries__salary!, OpenStruct.new(:RefCompta => '12345'), [Hash])
              end

              def put_submit(attrs = {})
                put '/bureau_consultant/statement_of_activities/submit', params: {
                  office_activity_report: {
                    consultant_comment: nil,
                    gross_wage: gross_wage
                  }.merge(attrs)
                }
              end

              it 'creates a DA' do
                assert_difference 'Goxygene::ActivityReport.count' do
                  put_submit
                end
              end

              it 'creates a DA with all the lines' do
                assert_difference 'Goxygene::ActivityReportLine.count', created_activities.count do
                  put_submit
                end
              end

              it 'does not create any DA expenses' do
                assert_no_difference 'Goxygene::ActivityReportExpense.count' do
                  put_submit
                end
              end

              it 'sets the right status for the DA' do
                put_submit

                assert_equal 'completed', current_da.activity_report_status
                assert_equal 'completed', current_da.activity_report_expense_status
              end

              it 'sets the right status for the DDA' do
                put_submit

                assert_equal 'completed', current_dda.activity_report_status
                assert_equal 'completed', current_dda.activity_report_expense_status
              end

              it 'sets the right status for the DA lines' do
                put_submit

                current_da.activity_report_lines.each do |line|
                  assert line.status == 'office_created' || line.status == 'itg_edited'
                end
              end

              it 'sets the right status for the DDA lines' do
                put_submit

                current_dda.office_activity_report_lines.each do |line|
                  assert_equal 'office_created', line.status
                end
              end

              it 'generates a new wage' do
                assert_difference 'Goxygene::Wage.count' do
                  put_submit
                end
              end

              it 'sets the created/updated by for the created wage' do
                put_submit

                assert_equal 296, Goxygene::Wage.last.created_by
                assert_equal 296, Goxygene::Wage.last.updated_by
              end
            end

            describe 'with some expenses' do
              let(:current_dda) { created_activities_with_expenses.first.office_activity_report.reload }
              let(:current_da)  { current_dda.activity_report                                          }

              before do
                created_activities_with_expenses

                Rails.cache.clear
                Accountancy = Minitest::Mock.new
                Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
                Accountancy.expect(:accounting_entries__salary!, OpenStruct.new(:RefCompta => '12345'), [Hash])
              end

              def put_submit(attrs = {})
                put '/bureau_consultant/statement_of_activities/submit', params: {
                  office_activity_report: {
                    consultant_comment: nil,
                    gross_wage: gross_wage
                  }.merge(attrs)
                }
              end

              it 'creates a DA' do
                assert_difference 'Goxygene::ActivityReport.count' do
                  put_submit
                end
              end

              it 'creates all the lines' do
                assert_difference 'Goxygene::ActivityReportLine.count', created_activities_with_expenses.count do
                  put_submit
                end
              end

              it 'creates all the expenses' do
                expenses_count = current_dda.office_activity_report_expenses.count
                assert_difference 'Goxygene::ActivityReportExpense.count', expenses_count do
                  put_submit
                end
              end

              it 'sets the right status for the DA' do
                put_submit

                assert_equal 'completed', current_da.activity_report_status
                assert_equal 'pending', current_da.activity_report_expense_status
              end

              it 'sets the right status for the DDA' do
                put_submit

                assert_equal 'completed', current_dda.activity_report_status
                assert_equal 'pending', current_dda.activity_report_expense_status
              end

              it 'sets the right status for the DA lines' do
                put_submit

                current_da.activity_report_lines.each do |line|
                  assert line.status == 'office_created' || line.status == 'itg_edited'
                end
              end

              it 'sets the right status for the DDA lines' do
                put_submit

                current_dda.office_activity_report_lines.each do |line|
                  assert_equal 'office_created', line.status
                end
              end

              it 'sets the right status for the DA expenses' do
                put_submit

                current_da.activity_report_expenses.each do |expense|
                  assert_equal 'office_created', expense.status
                end
              end

              it 'sets the right status for the DDA expenses' do
                put_submit

                current_dda.office_activity_report_expenses.each do |expense|
                  assert_equal 'office_created', expense.status
                end
              end

              it 'generates a new wage' do
                assert_difference 'Goxygene::Wage.count' do
                  put_submit
                end
              end
            end
          end

          describe 'validating activites only' do
            let(:current_dda) { created_activities_with_expenses.first.office_activity_report.reload }
            let(:current_da)  { current_dda.activity_report                                          }

            before do
              created_activities_with_expenses

              Rails.cache.clear
              Accountancy = Minitest::Mock.new
              Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
              Accountancy.expect(:accounting_entries__salary!, OpenStruct.new(:RefCompta => '12345'), [Hash])
            end

            def put_submit(attrs = {})
              put '/bureau_consultant/statement_of_activities/submit', params: {
                activities_only: 'true',
                office_activity_report: {
                  consultant_comment: nil,
                  gross_wage: gross_wage
                }.merge(attrs)
              }
            end

            it 'creates a DA' do
              assert_difference 'Goxygene::ActivityReport.count' do
                put_submit
              end
            end

            it 'creates all the lines' do
              assert_difference 'Goxygene::ActivityReportLine.count', created_activities_with_expenses.count do
                put_submit
              end
            end

            it 'does not create any DA expenses' do
              assert_no_difference 'Goxygene::ActivityReportExpense.count' do
                put_submit
              end
            end

            it 'sets the right status for the DA' do
              put_submit

              assert_equal 'completed', current_da.activity_report_status
              assert_equal 'office_editing', current_da.activity_report_expense_status
            end

            it 'sets the right status for the DDA' do
              put_submit

              assert_equal 'completed', current_dda.activity_report_status
              assert_equal 'office_editing', current_dda.activity_report_expense_status
            end

            it 'sets the right status for the DA lines' do
              put_submit

              current_da.activity_report_lines.each do |line|
                assert line.status == 'office_created' || line.status == 'itg_edited'
              end
            end

            it 'sets the right status for the DDA lines' do
              put_submit

              current_dda.office_activity_report_lines.each do |line|
                assert_equal 'office_created', line.status
              end
            end

            it 'generates a new wage' do
              assert_difference 'Goxygene::Wage.count' do
                put_submit
              end
            end
          end

        end


      end

      describe 'when the DDA was already validated' do
        def put_submit(attrs = {})
          put '/bureau_consultant/statement_of_activities/submit', params: {
            activities_only: 'true',
            office_activity_report: {
              consultant_comment: comment,
              gross_wage: current_soa.standard_gross_wage
            }.merge(attrs)
          }
        end

        let(:standard_gross_wage) { current_soa.standard_gross_wage }

        before do
          create_fresh_soa
          created_activities
          put_submit gross_wage: standard_gross_wage, consultant_comment: 'meh'
        end

        it 'does not update the DDA' do
          soa_id = current_soa.id

          put_submit

          soa = Goxygene::OfficeActivityReport.find(soa_id)

          assert_equal 'office_validated',  soa.activity_report_status
          assert_equal 'office_editing',    soa.activity_report_expense_status
          assert_equal standard_gross_wage, soa.gross_wage
          assert_equal 'meh',               soa.consultant_comment
        end

        it 'redirects to the history page' do
          put_submit

          assert_redirected_to '/bureau_consultant/statement_of_activities/first_time_da'
        end

      end
    end

    describe 'on the validate action' do
      before do
        create_fresh_soa
        created_activities_with_expenses

        Rails.cache.clear

        Accountancy = Minitest::Mock.new
        Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
      end

      it 'responds with success' do
        put '/bureau_consultant/statement_of_activities/validate', params: {
          office_activity_report: {
            consultant_comment: comment,
            gross_wage: gross_wage
          }
        }

        assert_response :success
      end
    end

    describe 'on the synthesis_2_calendar action' do
      before do
        create_fresh_soa
        created_activities
      end

      describe 'when a SOA is over DSN office date' do
        before do
          current_soa.update_columns month: 10
          current_soa.reload
        end

        it 'redirects to ...' do
          get '/bureau_consultant/statement_of_activities/first_time_new'

          assert_redirected_to '/bureau_consultant/statement_of_activities'
        end

        it 'set the opened SOA as rejected' do
          soa_id = current_soa.id

          get '/bureau_consultant/statement_of_activities/first_time_new'

          assert_equal 'rejected', consultant.office_activity_reports.find(soa_id).activity_report_status
        end
      end

      it 'renders the page' do
        get '/bureau_consultant/statement_of_activities/synthesis_2_calendar'

        assert_response :success
      end

      describe 'when consultant have expenses reimbursed' do
        it 'includes a previous link to the expenses page' do
          get '/bureau_consultant/statement_of_activities/synthesis_2_calendar'

          assert_select 'a', href: "/bureau_consultant/statement_of_activities/mission_expense", text: 'PRÉCÉDENT'
        end
      end

      describe 'when consultant does not have expenses reimbursed' do
        before { consultant.update granted_expenses: false }

        it 'includes a previous link to the activities' do
          get '/bureau_consultant/statement_of_activities/synthesis_2_calendar'

          assert_select 'a', href: "/bureau_consultant/statement_of_activities/new#manage_zipcode", text: 'PRÉCÉDENT'
        end
      end
    end

    describe 'on the synthesis 2 step action' do
      describe 'with a soa in edition' do
        before { created_activities_with_expenses }

        it 'renders the page' do
          get '/bureau_consultant/statement_of_activities/synthesis_2_step'

          assert_response :success
        end
      end

      describe 'with no soa in edition' do
        describe 'with a negative balance' do
          before do
            Rails.cache.clear

            Accountancy = Minitest::Mock.new
            Accountancy.expect(:consultant_account_balances, negative_balances, [consultant.id, environment: "FREELAND", clear_cache: true])

            consultant.office_activity_reports.in_edition.destroy_all

            get '/bureau_consultant/statement_of_activities/synthesis_2_step',
                params: {
                  statement_of_activities_request: {
                    date: Date.current.beginning_of_month.strftime
                  }
                }
          end

          it 'renders the page' do
            assert_response :success
          end

          it 'displays the maximum gross_wage available' do
            assert_select 'span#max_salary', '0.0'
          end

          it 'calls the Accountancy API to fetch the maximum salary available' do
            assert_mock Accountancy
          end
        end

        describe 'with a positive balance' do
          before do
            Rails.cache.clear

            Accountancy = Minitest::Mock.new
            Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])

            consultant.office_activity_reports.in_edition.destroy_all

            get '/bureau_consultant/statement_of_activities/synthesis_2_step',
                params: {
                  statement_of_activities_request: {
                    date: Date.current.beginning_of_month.strftime
                  }
                }
          end

          it 'renders the page' do
            assert_response :success
          end

          it 'displays the maximum gross_wage available' do
            assert_select 'span#max_salary', '51148.05'
          end

          it 'calls the Accountancy API to fetch the maximum salary available' do
            assert_mock Accountancy
          end
        end

      end
    end

    describe 'on the synthesis 3 step action' do
      before do
        create_fresh_soa
        created_activities_with_expenses
      end

      describe 'when a SOA is over DSN office date' do
        before do
          current_soa.update_columns month: 10
          current_soa.reload
        end

        it 'redirects to ...' do
          get '/bureau_consultant/statement_of_activities/first_time_new'

          assert_redirected_to '/bureau_consultant/statement_of_activities'
        end

        it 'set the opened SOA as rejected' do
          soa_id = current_soa.id

          get '/bureau_consultant/statement_of_activities/first_time_new'

          assert_equal 'rejected', consultant.office_activity_reports.find(soa_id).activity_report_status
        end
      end

      it 'renders the page' do
        get '/bureau_consultant/statement_of_activities/synthesis_3_step'

        assert_response :success
      end
    end

    describe 'on the destroy expense action' do
      def delete_destroy_expense(expense_id: nil, activity_id: nil)
        activity = created_activities_with_expenses.select {|a| a.office_activity_report_expenses.any? }.last
        expense  = activity.office_activity_report_expenses.last

        delete '/bureau_consultant/statement_of_activities/destroy_expense', params: {
          activity_id: activity_id || activity.id,
          expense_id:  expense_id  || expense.id
        }
      end

      describe 'when a SOA is in edition' do
        before { created_activities_with_expenses }

        it 'deletes the expense from database' do
          assert_difference 'Goxygene::OfficeActivityReportExpense.count', -1 do
            delete_destroy_expense
          end
        end

        it 'redirects to the manage mission action' do
          delete_destroy_expense
          assert_redirected_to '/bureau_consultant/statement_of_activities/manage_mission'
        end

      end

      describe 'when a SOA has its activities validated' do
        before do
          current_soa.update! consultant_comment: 'preventing auto-acceptance'
          current_soa.submit! :activities
          created_activities_with_expenses
        end

        it 'deletes the expense from database' do
          assert_difference 'Goxygene::OfficeActivityReportExpense.count', -1 do
            delete_destroy_expense
          end
        end

        it 'redirects to the manage mission page' do
          delete_destroy_expense
          assert_redirected_to '/bureau_consultant/statement_of_activities/manage_mission'
        end
      end

      describe 'when the consultant does not have expenses refunded' do
        before do
          consultant.update! granted_expenses: false
          created_activities_with_expenses
        end

        it 'redirects to synthesis_3_step' do
          delete_destroy_expense
          assert_redirected_to '/bureau_consultant/statement_of_activities/synthesis_3_step'
        end

        it 'does not delete anything in the database' do
          assert_no_difference 'Goxygene::OfficeActivityReportExpense.count' do
            delete_destroy_expense
          end
        end
      end
    end

    describe 'on the update expense action' do

      let(:kilometer_cost) { (current_soa.vehicle_taxe_weight.rate1 * kilometers).round(2) }

      def post_update_expense(attrs: {}, expense_id: nil, activity_id: nil)
        post '/bureau_consultant/statement_of_activities/update_expense', params: {
              activity_id: activity_id || existing_entry.id,
              expense_id:  expense_id,
              office_activity_report_expense: {
                expense_type_id:  expense_type.id,
                total:            expense_with_vat,
                label:            expense_label,
                vat:              ''
              }.merge(attrs)
            }.compact
      end

      describe 'when a SOA is in edition' do
        describe 'when creating a new entry' do
          describe 'when unemployment_rate == 0' do
            before { consultant.update! payroll_hourly_wages: 0 }

            it 'creates the expense' do
              assert_difference 'Goxygene::OfficeActivityReportExpense.count' do
                post_update_expense
              end
            end

            it 'redirects to the manage mission action' do
              post_update_expense
              assert_redirected_to "/bureau_consultant/statement_of_activities/manage_mission?activity_id=#{existing_entry.id}"
            end
          end

          describe 'when entry is valid' do

            let(:last_line) { Goxygene::OfficeActivityReportExpense.last }

            it 'creates the expense' do
              assert_difference 'Goxygene::OfficeActivityReportExpense.count' do
                post_update_expense
              end
            end

            it 'sets the posted attributes' do
              post_update_expense

              assert_equal expense_type.id,  last_line.expense_type_id
              assert_equal expense_with_vat, last_line.total
              assert_equal expense_label,    last_line.label
            end

            it 'updates the SOA perdiem_cost' do
              old_perdiem_cost = current_soa.perdiem_cost.to_f

              post_update_expense attrs: {
                total: expense_with_vat,
                expense_type_id: 12
              }

              assert_equal old_perdiem_cost + expense_with_vat, current_soa.reload.perdiem_cost
            end

            it 'updates the SOA totals' do
              old = current_soa.slice :expenses, :expenses_with_taxes

              post_update_expense

              current_soa.reload

              old.each { |key, old_value| assert_equal old_value + expense_with_vat, current_soa.send(key) }
            end

            it 'updates the SOA expenses vat' do
              old = current_soa.expenses_vat

              post_update_expense attrs: {
                vat: expense_with_vat / 10,
                expense_type_id: Goxygene::ExpenseType.has_vat.for_activities.shuffle.first.id
              }

              assert_equal old + (expense_with_vat / 10), current_soa.reload.expenses_vat
            end

            describe 'when creating the first expense' do
              it 'assigns 1 to the item number' do
                post_update_expense

                assert_equal 1, last_line.proof_of_expense_number
              end
            end

            describe 'when creating the second expense' do
              it 'assigns 2 to the item number' do
                existing_expense # to create a first expense

                post_update_expense

                assert_equal 2, last_line.proof_of_expense_number
              end
            end

            it 'redirects to the manage mission action' do
              post_update_expense
              assert_redirected_to "/bureau_consultant/statement_of_activities/manage_mission?activity_id=#{existing_entry.id}"
            end

            describe 'when creating a distance expense' do
              let(:expense)    { Goxygene::OfficeActivityReportExpense.last }
              let(:kilometers) { rand(123) }

              before do
                post_update_expense attrs: {
                  expense_type_id: distance_expense_type,
                  kilometers: kilometers,
                  total: 0,
                  vat: 0
                }
              end

              it 'sets total to zero' do
                assert_equal 0, expense.total
              end

              it 'sets the kilometers' do
                assert_equal kilometers, expense.kilometers
              end

              it 'sets the vat to zero' do
                assert_equal 0, expense.vat
              end

              it 'sets the label' do
                assert_equal expense_label, expense.label
              end

              it 'sets the DA kilometer_cost' do
                assert_equal kilometer_cost, current_soa.reload.kilometer_cost
              end

              it 'updates the DA expenses with the kilometer_cost' do
                assert_equal current_soa.expenses + kilometer_cost, current_soa.reload.expenses
              end

              it 'updates the DA expenses_with_taxes with the kilometer_cost' do
                assert_equal current_soa.expenses_with_taxes + kilometer_cost, current_soa.reload.expenses_with_taxes
              end
            end
          end

          describe 'when vat is higher than total' do
            it 'does not create the expense' do
              assert_no_difference 'Goxygene::OfficeActivityReportExpense.count' do
                post_update_expense attrs: { vat: expense_with_vat + 1 }
              end
            end

            it 'renders an error message' do
              post_update_expense attrs: { vat: expense_with_vat + 1 }
              assert_response :success
            end
          end

          describe 'when label is missing' do
            it 'does not create the expense' do
              assert_no_difference 'Goxygene::OfficeActivityReportExpense.count' do
                post_update_expense attrs: { label: '' }
              end
            end

            it 'renders an error message' do
              post_update_expense attrs: { label: '' }
              assert_response :success
            end
          end

          describe 'when expense is missing' do
            it 'does not create the expense' do
              assert_no_difference 'Goxygene::OfficeActivityReportExpense.count' do
                post_update_expense attrs: { total: '' }
              end
            end

            it 'renders an error message' do
              post_update_expense attrs: { total: '' }
              assert_response :success
            end
          end
        end

        describe 'when updating an existing entry' do
          before { existing_expense }

          describe 'when entry is valid' do
            it 'updates the expense' do
              assert_no_difference 'Goxygene::OfficeActivityReportExpense.count' do
                post_update_expense expense_id: existing_expense.id
              end

              last_line = Goxygene::OfficeActivityReportExpense.last

              assert_equal expense_type.id,  last_line.expense_type_id
              assert_equal expense_with_vat, last_line.total
              assert_equal expense_label,    last_line.label
            end

            it 'redirects to the manage mission action' do
              post_update_expense expense_id: existing_expense.id

              assert_redirected_to "/bureau_consultant/statement_of_activities/manage_mission?activity_id=#{existing_entry.id}"
            end

            it 'does not fail when a null kilometer value is posted' do
              post_update_expense expense_id: existing_expense.id, attrs: {
                expense_type_id: distance_expense_type,
                kilometers: nil
              }

              assert_redirected_to "/bureau_consultant/statement_of_activities/manage_mission?activity_id=#{existing_entry.id}"
            end

            describe 'when changing type to a distance expense' do
              let(:kilometers) { rand(123) }
              let!(:expenses) { current_soa.expenses }
              let!(:expenses_with_taxes) { current_soa.expenses_with_taxes }

              before do
                assert_not_equal distance_expense_type, existing_expense.expense_type_id

                post_update_expense expense_id: existing_expense.id, attrs: {
                  expense_type_id: distance_expense_type,
                  kilometers: kilometers
                }
              end

              it 'sets total to zero' do
                assert_equal 0, existing_expense.reload.total
              end

              it 'sets the kilometers' do
                assert_equal kilometers, existing_expense.reload.kilometers
              end

              it 'sets the vat to zero' do
                assert_equal 0, existing_expense.reload.vat
              end

              it 'sets the label' do
                assert_equal expense_label, existing_expense.reload.label
              end

              it 'sets the DA kilometer_cost' do
                assert_equal kilometer_cost, current_soa.reload.kilometer_cost
              end

              it 'updates the DA expenses_with_taxes with the kilometer_cost' do
                assert_equal expenses_with_taxes + kilometer_cost, current_soa.reload.expenses_with_taxes
              end
            end

            describe 'when changing type from a distance expense' do
              let(:total) { 1 + rand(123) }

              before do
                assert_equal distance_expense_type, existing_distance_expense.expense_type_id

                post_update_expense expense_id: existing_distance_expense.id, attrs: {
                  expense_type_id: 5,
                  total: total
                }
              end

              it 'sets the total' do
                assert_equal total, existing_distance_expense.reload.total
              end

              it 'sets the kilometers to zero' do
                assert_equal 0, existing_distance_expense.reload.kilometers
              end

              it 'sets the label' do
                assert_equal expense_label, existing_distance_expense.reload.label
              end

              it 'sets the DA kilometer_cost' do
                assert_equal 0, current_soa.reload.kilometer_cost
              end
            end
          end

          describe 'when label is missing' do
            it 'does not create the expense' do
              assert_no_difference 'Goxygene::OfficeActivityReportExpense.count' do
                post_update_expense attrs: { label: '' }, expense_id: existing_expense.id
              end
            end

            it 'renders an error message' do
              post_update_expense attrs: { label: '' }, expense_id: existing_expense.id
              assert_response :success
            end
          end

          describe 'when expense is missing' do
            it 'does not create the expense' do
              assert_no_difference 'Goxygene::OfficeActivityReportExpense.count' do
                post_update_expense attrs: { total: '' }, expense_id: existing_expense.id
              end
            end

            it 'renders an error message' do
              post_update_expense attrs: { total: '' }, expense_id: existing_expense.id
              assert_response :success
            end
          end
        end

        describe 'when the consultant does not have expenses refunded' do
          before { consultant.update! granted_expenses: false }

          it 'redirects to synthesis_3_step' do
            post_update_expense activity_id: created_activities.last.id

            assert_redirected_to '/bureau_consultant/statement_of_activities/synthesis_3_step'
          end
        end
      end

      describe 'when a SOA has its activities validated' do
        before do
          created_activities_with_expenses
          current_soa.reload
          current_soa.gross_wage = current_soa.standard_gross_wage
          current_soa.submit! :activities
        end

        it 'redirects to the manage mission page' do
          post_update_expense activity_id: created_activities.last.id
          assert_redirected_to "/bureau_consultant/statement_of_activities/manage_mission?activity_id=#{created_activities.last.id}"
        end
      end
    end

    describe 'on the manage mission expense action' do

      def get_manage_mission_expense(expense_id: nil, activity_id: nil)
        activity = created_activities_with_expenses.select {|a| a.office_activity_report_expenses.any? }.last
        expense  = activity.office_activity_report_expenses.last

        get '/bureau_consultant/statement_of_activities/manage_mission_expense', params: {
          activity_id: activity_id || activity.id,
          expense_id:  expense_id  || expense.id
        }
      end

      describe 'when the consultant can have expenses refunded' do
        it 'renders the page' do
          created_activities_with_expenses

          get_manage_mission_expense

          assert_response :success
        end

        describe 'when the consultant has a vehicle taxe weight' do
          before do
            consultant.update vehicle: Goxygene::Vehicle.last
            current_soa.update vehicle_taxe_weight_id: consultant.vehicle.vehicle_taxe_weight_id
          end

          it 'displays the taxe_weight label' do
            created_activities_with_expenses

            get_manage_mission_expense

            assert_select 'div', 'Ch. Fiscaux'
          end

          it 'displays the taxe_weight value' do
            created_activities_with_expenses

            get_manage_mission_expense

            assert_select 'div.vehicle_taxe_weight', { text: consultant.vehicle.vehicle_taxe_weight.taxe_weigth.to_s }
          end

        end

        describe 'when the current SOA has only activities validated' do
          before do
            created_activities_with_expenses.last
            current_soa.reload.update! activity_report_status: :office_validated,
                                       gross_wage: current_soa.standard_gross_wage
          end

          it 'renders the page' do
            get_manage_mission_expense

            assert_response :success
          end
        end

        describe 'when the current SOA is not in expenses edition mode' do
          before do
            created_activities_with_expenses.last
            current_soa.reload.update! activity_report_expense_status: :office_validated
          end

          it 'redirects to synthesis_3_step' do
            get_manage_mission_expense

            assert_redirected_to '/bureau_consultant/statement_of_activities/synthesis_3_step'
          end
        end
      end

      describe 'when the consultant does not have expenses refunded' do
        before do
          consultant.update! granted_expenses: false
          created_activities
        end

        it 'redirects to synthesis_3_step' do
          get_manage_mission_expense

          assert_redirected_to '/bureau_consultant/statement_of_activities/synthesis_3_step'
        end
      end
    end

    describe 'on the manage mission action' do
      describe 'when the consultant can have expenses refunded' do
        before do
          created_activities_with_expenses

          get '/bureau_consultant/statement_of_activities/manage_mission'
        end

        it 'renders the page' do
          assert_response :success
        end

        it 'includes the item number for expense' do
          current_soa.office_activity_report_expenses.each do |expense|
            assert_select 'div.visible-xs span.expense_item_number', expense.proof_of_expense_number.to_s
            assert_select 'div.hidden-xs span.expense_item_number', expense.proof_of_expense_number.to_s
          end
        end

        it 'orders the expenses by item number' do
          css_select("div.activity").each do |activity|
            previous = nil

            activity.css("table.expenses td span.expense_item_number").each do |entry|
              if previous.nil?
                previous = entry
                next
              end

              assert entry.content.to_i > previous.content.to_i

              previous = entry
            end
          end
        end

        describe 'when an activity has been rejected' do
          let(:rejected_activity) { created_activities_with_expenses.last }

          before do
            rejected_activity.update status: 'itg_rejected'
          end

          it 'does not display the expense addition form for the rejected activity' do
            get '/bureau_consultant/statement_of_activities/manage_mission'

            assert_select "div.activity##{rejected_activity.id} form input[type=text]", { count: 0 }
          end

          it 'does not display the expense edition/deletion buttons for the rejected activity' do
            get '/bureau_consultant/statement_of_activities/manage_mission'

            assert_select "div.activity##{rejected_activity.id} form a", { count: 0 }
          end

          it 'keeps displaying the expense addition form for other activities' do
            get '/bureau_consultant/statement_of_activities/manage_mission'

            created_activities_with_expenses.each do |activity|
              next if activity == rejected_activity
              assert_select "div.activity##{activity.id} form input[type=text]"
            end

          end

          it 'keeps displaying the expenses edition/deletion buttons for other activities' do
            get '/bureau_consultant/statement_of_activities/manage_mission'

            created_activities_with_expenses.each do |activity|
              next if activity == rejected_activity
              assert_select "div.activity##{activity.id} form a"
            end

          end
        end

        describe 'when the current SOA is not in expenses edition mode' do
          before do
            created_activities_with_expenses.last
            current_soa.reload.update! activity_report_expense_status: :office_validated
          end

          it 'redirects to synthesis_3_step' do
            get '/bureau_consultant/statement_of_activities/manage_mission'

            assert_redirected_to '/bureau_consultant/statement_of_activities/synthesis_3_step'
          end
        end
      end

      describe 'when the consultant does not have expenses refunded' do
        before do
          consultant.update! granted_expenses: false
          created_activities
        end

        it 'redirects to synthesis_3_step' do
          get '/bureau_consultant/statement_of_activities/manage_mission'

          assert_redirected_to '/bureau_consultant/statement_of_activities/synthesis_3_step'
        end
      end
      
    end

    describe 'on the mission expense action' do
      describe 'when the consultant can have expenses refunded' do
        before do
          create_fresh_soa
          created_activities_with_expenses
        end

        it 'renders the page' do
          get '/bureau_consultant/statement_of_activities/mission_expense'

          assert_response :success
        end

        describe 'when a SOA is over DSN office date' do
          before do
            current_soa.update_columns month: 10
            current_soa.reload
          end

          it 'renders the page' do
            get '/bureau_consultant/statement_of_activities/mission_expense'

            assert_response :success
          end

          it 'does not set the opened SOA as rejected' do
            soa_id = current_soa.id

            get '/bureau_consultant/statement_of_activities/mission_expense'

            assert_equal 'office_editing', consultant.office_activity_reports.find(soa_id).activity_report_status
          end
        end

        describe 'when the current SOA is not in expenses edition mode' do
          before do
            current_soa.reload.update! activity_report_expense_status: :office_validated
          end

          it 'redirects to synthesis_3_step' do
            get '/bureau_consultant/statement_of_activities/mission_expense'

            assert_redirected_to '/bureau_consultant/statement_of_activities/synthesis_3_step'
          end
        end
      end

      describe 'when the consultant does not have expenses refunded' do
        before do
          consultant.update! granted_expenses: false
          create_fresh_soa
          created_activities
        end

        it 'redirects to synthesis_3_step' do
          get '/bureau_consultant/statement_of_activities/mission_expense'

          assert_redirected_to '/bureau_consultant/statement_of_activities/synthesis_3_step'
        end
      end
    end

    describe 'on the update mission location action' do
      describe 'when a consultant can have expenses refunded' do
        before do
          create_fresh_soa
          created_activities_with_expenses
        end

        describe 'when a SOA is over DSN office date' do
          before do
            current_soa.update_columns month: 10
            current_soa.reload
          end

          it 'redirects to ...' do
            patch '/bureau_consultant/statement_of_activities/update_mission_location', params: {
              office_activity_report: {
                mission_in_foreign_country: false,
                mission_zip_code: '12345'
              }
            }

            assert_redirected_to '/bureau_consultant/statement_of_activities'
          end

          it 'set the opened SOA as rejected' do
            soa_id = current_soa.id

            patch '/bureau_consultant/statement_of_activities/update_mission_location', params: {
              office_activity_report: {
                mission_in_foreign_country: false,
                mission_zip_code: '12345'
              }
            }

            assert_equal 'rejected', consultant.office_activity_reports.find(soa_id).activity_report_status
          end
        end

        it 'saves the mission location and zipcode in database' do
          patch '/bureau_consultant/statement_of_activities/update_mission_location', params: {
            office_activity_report: {
              mission_in_foreign_country: false,
              mission_zip_code: '12345'
            }
          }

          assert_equal '12345', current_soa.reload.mission_zip_code
          assert_equal false,   current_soa.reload.mission_in_foreign_country
        end


        it 'redirects to the mission expenses action' do
          patch '/bureau_consultant/statement_of_activities/update_mission_location', params: {
            office_activity_report: {
              mission_in_foreign_country: false,
              mission_zip_code: '12345'
            }
          }

          assert_redirected_to '/bureau_consultant/statement_of_activities/mission_expense'
        end

        describe 'when mission country is france' do
          it 'requires a mission location zipcode' do
            patch '/bureau_consultant/statement_of_activities/update_mission_location', params: {
              office_activity_report: {
                mission_in_foreign_country: false,
                mission_zip_code: ''
              }
            }

            assert_response :success
          end
        end

        describe 'when mission location is in a foreign country' do
          it 'does not require a mission location' do
            patch '/bureau_consultant/statement_of_activities/update_mission_location', params: {
              office_activity_report: {
                mission_in_foreign_country: true,
                mission_zip_code: ''
              }
            }

            assert_redirected_to '/bureau_consultant/statement_of_activities/mission_expense'
          end
        end
      end

      describe 'when a consultant does not have refunds on expenses' do
        before do
          consultant.update! granted_expenses: false
          create_fresh_soa
          created_activities
        end

        it 'redirects to the synthesis 2 action' do
          patch '/bureau_consultant/statement_of_activities/update_mission_location', params: {
            office_activity_report: {
              mission_in_foreign_country: false,
              mission_zip_code: '12345'
            }
          }

          assert_redirected_to '/bureau_consultant/statement_of_activities/synthesis_2_calendar'
        end
      end
    end

    describe 'on the duplicate activity on month action' do
      before do
        create_fresh_soa

        Rails.cache.clear
        Accountancy = Minitest::Mock.new
        Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
      end

      def post_duplicate_activity_on_month(attrs: {}, line_id: nil)
        post '/bureau_consultant/statement_of_activities/duplicate_activity_on_month', params: {
              date:    activity_date.strftime('%Y-%m-%d'),
              line_id: line_id,
              office_activity_report_line: {
                activity_type_id: activity_type.id,
                label:            label,
                time_span:        0.25,
              }.merge(attrs)
            }
      end

      let(:days_for_current_month) do
        (current_soa.date.beginning_of_month..current_soa.date.end_of_month).reject do |day|
          day.saturday? || day.sunday?
        end
      end

      describe 'when a SOA is in edition' do
        describe 'on a new activity' do
          it 'duplicates the activity over the entire month' do
            assert_difference 'Goxygene::OfficeActivityReportLine.count', days_for_current_month.count do
              post_duplicate_activity_on_month
            end

            current_soa.office_activity_report_lines.each do |activity|
              assert_equal activity_type.id, activity.activity_type_id
              assert_equal label,            activity.label
              assert_equal 0.25,             activity.time_span
            end
          end

          it 'does not duplicate the activity over the selected day' do
            post_duplicate_activity_on_month

            activity_dates = current_soa.office_activity_report_lines.collect(&:date)

            assert_equal activity_dates.uniq.count, activity_dates.count
          end

          it 'redirects to the new action' do
            post_duplicate_activity_on_month

            assert_redirected_to '/bureau_consultant/statement_of_activities/new'
          end

          it 'reloads consultant cumuls' do
            post_duplicate_activity_on_month

            assert_mock Accountancy
          end

          it 'updates the counts' do
            days                = current_soa.work_days + current_soa.enhancement_days
            hours               = current_soa.hours
            standard_gross_wage = current_soa.standard_gross_wage

            post_duplicate_activity_on_month

            current_soa.reload

            assert_equal days + (days_for_current_month.count * 0.25), current_soa.work_days + current_soa.enhancement_days
            assert_not_equal standard_gross_wage, current_soa.standard_gross_wage
          end

          it 'displays an error message if activity was not created' do
            date = current_soa.date + 1.day
            # ensure the day we add the activity is not on WE
            # because the duplication code does not create
            # activities on we
            while date.saturday? || date.sunday?
              date += 1.day
            end

            current_soa.office_activity_report_lines.create!(
              activity_type: Goxygene::ActivityType.mission_or_development.active.shuffle.first,
              time_span:     1,
              label:         FFaker::Lorem.words(5).join(' '),
              date:          date,
              created_by:    cas_authentications(:jackie_denesik).cas_user.id,
              updated_by:    cas_authentications(:jackie_denesik).cas_user.id,
            )

            post_duplicate_activity_on_month
            get '/bureau_consultant/statement_of_activities/new'

            assert_select 'div#error_explanation ul li', "L'activité n'a pas pu être dupliquée sur les dates suivantes : #{date.strftime("%d-%m-%Y")}"
          end

          it 'displays an error message if consultant does not have a contract' do
            consultant.employment_contracts.destroy_all
            consultant.update payroll_contract_type: nil

            post_duplicate_activity_on_month
            assert_redirected_to '/bureau_consultant/statement_of_activities/new'

            get '/bureau_consultant/statement_of_activities/new'
            assert_select 'div#error_explanation ul li', "Votre compte ne permet pas la création d'une Déclaration d'Activités, veuillez contacter votre conseiller"
          end
        end

        describe 'on an existing activity' do
          before { existing_entry }

          it 'duplicates the activity over the selected days' do
            assert_difference 'Goxygene::OfficeActivityReportLine.count', days_for_current_month.count do
              post_duplicate_activity_on_month line_id: existing_entry.id
            end

            current_soa.office_activity_report_lines.each do |activity|
              next if activity == existing_entry

              assert_equal activity_type.id, activity.activity_type_id
              assert_equal label,            activity.label
              assert_equal 0.25,             activity.time_span
            end
          end

          it 'redirects to the new action' do
            post_duplicate_activity_on_month line_id: existing_entry.id

            assert_redirected_to '/bureau_consultant/statement_of_activities/new'
          end

          it 'reloads consultant cumuls' do
            post_duplicate_activity_on_month line_id: existing_entry.id

            assert_mock Accountancy
          end

          it 'updates the counts' do
            days                = current_soa.work_days + current_soa.enhancement_days
            hours               = current_soa.hours
            standard_gross_wage = current_soa.standard_gross_wage

            post_duplicate_activity_on_month line_id: existing_entry.id

            current_soa.reload

            assert_equal days + (days_for_current_month.count * 0.25), current_soa.work_days + current_soa.enhancement_days
            assert_not_equal standard_gross_wage, current_soa.standard_gross_wage
          end
        end
      end

      describe 'when a SOA has its activities validated' do
        before do
          current_soa.update! consultant_comment: 'preventing auto-acceptance'
          current_soa.submit! :activities
        end

        it 'redirects to the manage mission page' do
          post_duplicate_activity_on_month
          assert_redirected_to '/bureau_consultant/statement_of_activities/manage_mission'
        end
      end
    end

    describe 'on the duplicate few days action' do
      before do
        create_fresh_soa

        Rails.cache.clear
        Accountancy = Minitest::Mock.new
        Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
      end

      let(:dates_for_duplication) do
        [
          activity_date +  2.days,
          activity_date +  3.days,
          activity_date +  4.days,
          activity_date + 10.days,
        ]
      end

      def post_duplicate_few_days(attrs: {}, dates: [], line_id: nil)
        post '/bureau_consultant/statement_of_activities/duplicate_few_days', params: {
              duplicated_line: {
                date: activity_date.strftime('%Y-%m-%d'),
                line_id: line_id,
                selected_dates: {
                  data: dates + dates_for_duplication.collect { |date| date.strftime('%Y-%m-%d') }
                }.to_json
              },
              office_activity_report_line: {
                activity_type_id: activity_type.id,
                label:            label,
                time_span:        time_span,
              }.merge(attrs)
            }
      end

      describe 'when a SOA is in edition' do
        describe 'on a new activity' do
          it 'duplicates the activity over the selected days' do
            assert_difference 'Goxygene::OfficeActivityReportLine.count', dates_for_duplication.count + 1 do
              post_duplicate_few_days
            end

            current_soa.office_activity_report_lines.each do |activity|
              assert (dates_for_duplication + [activity_date]).include? activity.date

              assert_equal activity_type.id, activity.activity_type_id
              assert_equal label,            activity.label
              assert_equal time_span,        activity.time_span
            end
          end

          it 'redirects to the new action' do
            post_duplicate_few_days

            assert_redirected_to '/bureau_consultant/statement_of_activities/new'
          end

          it 'reloads cumuls for the consultant' do
            post_duplicate_few_days

            assert_mock Accountancy
          end

          it 'updates the counts' do
            days                = current_soa.work_days + current_soa.enhancement_days
            hours               = current_soa.hours
            standard_gross_wage = current_soa.standard_gross_wage

            post_duplicate_few_days

            current_soa.reload

            assert_equal days + ((dates_for_duplication.count + 1) * time_span), current_soa.work_days + current_soa.enhancement_days
            assert_not_equal standard_gross_wage, current_soa.standard_gross_wage
          end

          it 'displays an error message if consultant does not have a contract' do
            consultant.employment_contracts.destroy_all
            consultant.update payroll_contract_type: nil

            post_duplicate_few_days
            assert_redirected_to '/bureau_consultant/statement_of_activities/new'

            get '/bureau_consultant/statement_of_activities/new'
            assert_select 'div#error_explanation ul li', "Votre compte ne permet pas la création d'une Déclaration d'Activités, veuillez contacter votre conseiller"
          end
        end

        describe 'on an existing activity' do
          before { existing_entry }

          it 'duplicates the activity over the selected days' do
            assert_difference 'Goxygene::OfficeActivityReportLine.count', dates_for_duplication.count do
              post_duplicate_few_days line_id: existing_entry.id
            end

            current_soa.office_activity_report_lines.each do |activity|
              next if activity == existing_entry

              assert dates_for_duplication.include? activity.date

              assert_equal activity_type.id, activity.activity_type_id
              assert_equal label,            activity.label
              assert_equal time_span,        activity.time_span
            end
          end

          it 'redirects to the new action' do
            post_duplicate_few_days line_id: existing_entry.id

            assert_redirected_to '/bureau_consultant/statement_of_activities/new'
          end

          it 'reloads cumuls for the consultant' do
            post_duplicate_few_days line_id: existing_entry.id

            assert_mock Accountancy
          end

          it 'updates the counts' do
            days                = current_soa.work_days + current_soa.enhancement_days
            hours               = current_soa.hours
            standard_gross_wage = current_soa.standard_gross_wage

            post_duplicate_few_days line_id: existing_entry.id

            current_soa.reload

            assert_equal days + (dates_for_duplication.count * time_span), current_soa.work_days + current_soa.enhancement_days
            assert_not_equal standard_gross_wage, current_soa.standard_gross_wage
          end
        end
      end

      describe 'when a SOA has its activities validated' do
        before do
          current_soa.reload.update! consultant_comment: 'preventing auto-acceptance'
          current_soa.reload.submit! :activities
        end

        it 'redirects to the manage mission page' do
          post_duplicate_few_days
          assert_redirected_to '/bureau_consultant/statement_of_activities/manage_mission'
        end
      end
    end

    describe 'on the duplicate new action' do
      before { create_fresh_soa }

      def post_duplicate_new(attrs: {}, line_id: nil)
        post '/bureau_consultant/statement_of_activities/duplicate_new', params: {
              date:    activity_date.strftime('%Y-%m-%d'),
              line_id: line_id,
              office_activity_report_line: {
                activity_type_id: activity_type.id,
                label:            label,
                time_span:        time_span,
              }.merge(attrs)
            }
      end

      describe 'when a SOA is in edition' do

        describe 'when creating a new entry' do
          describe 'when entry is valid' do
            it 'shows the duplication form' do
              post_duplicate_new

              assert_response :success

              assert_select 'form[action="/bureau_consultant/statement_of_activities/duplicate_few_days"]'

              assert_equal activity_date.strftime('%Y-%m-%d'),
                           css_select('form input#duplicated_line_date').first['value']

              assert_equal activity_type.id.to_s,
                           css_select('form input#office_activity_report_line_activity_type_id').first['value']

              assert_equal label,
                           css_select('form input#office_activity_report_line_label').first['value']

              assert_equal time_span.to_f.to_s,
                           css_select('form input#office_activity_report_line_time_span').first['value']
            end

            it 'does not create a new entry in database' do
              assert_no_difference 'Goxygene::OfficeActivityReportLine.count' do
                post_duplicate_new
              end
            end
          end

          describe 'when the total for current day is higher than 1 day' do
            before { existing_entry }

            it 'does not render the duplication form'

            it 'renders an error message'
          end

          describe 'when label is missing' do
            before { post_duplicate_new attrs: { label: nil } }

            it 'does not render the duplication form' do
              assert_select 'form#new_office_activity_report_line'
            end

            it 'renders an error message' do
              assert_select 'div#error_explanation'
            end
          end

          describe 'when duration is missing' do
            before { post_duplicate_new attrs: { time_span: nil } }

            it 'does not render the duplication form' do
              assert_select 'form#new_office_activity_report_line'
            end

            it 'renders an error message' do
              assert_select 'div#error_explanation'
            end
          end
        end

        describe 'when updating an existing entry' do
          before { existing_entry }

          describe 'when entry is valid' do
            it 'shows the duplication form' do
              post_duplicate_new line_id: existing_entry.id

              assert_response :success

              assert_select 'form[action="/bureau_consultant/statement_of_activities/duplicate_few_days"]'

              assert_equal activity_date.strftime('%Y-%m-%d'),
                           css_select('form input#duplicated_line_date').first['value']

              assert_equal activity_type.id.to_s,
                           css_select('form input#office_activity_report_line_activity_type_id').first['value']

              assert_equal label,
                           css_select('form input#office_activity_report_line_label').first['value']

              assert_equal time_span.to_f.to_s,
                           css_select('form input#office_activity_report_line_time_span').first['value']
            end

            it 'does not create a new activity' do
              assert_no_difference 'Goxygene::OfficeActivityReportLine.count' do
                post_duplicate_new line_id: existing_entry.id
              end
            end
          end

          describe 'when the total for current day is higher than 1 day' do
            before do
              current_soa.office_activity_report_lines.create!(
                activity_type: Goxygene::ActivityType.mission_or_development.active.shuffle.first,
                time_span:     0.25,
                label:         FFaker::Lorem.words(5).join(' '),
                date:          activity_date,
                created_by:    cas_authentications(:jackie_denesik).cas_user.id,
                updated_by:    cas_authentications(:jackie_denesik).cas_user.id
              )
            end

            it 'does not render the duplication form'

            it 'renders an error message'
          end

          describe 'when label is missing' do
            before { post_duplicate_new attrs: { label: nil }, line_id: existing_entry.id }

            it 'does not render the duplication form' do
              assert_select "form#edit_office_activity_report_line_#{existing_entry.id}"
            end

            it 'renders an error message' do
              assert_select 'div#error_explanation'
            end
          end

          describe 'when duration is missing' do
            before { post_duplicate_new attrs: { time_span: nil }, line_id: existing_entry.id }

            it 'does not render the duplication form' do
              assert_select "form#edit_office_activity_report_line_#{existing_entry.id}"
            end

            it 'renders an error message' do
              assert_select 'div#error_explanation'
            end
          end
        end
      end

      describe 'when a SOA has its activities validated' do
        before do
          current_soa.update! consultant_comment: 'preventing auto-acceptance'
          current_soa.submit! :activities
        end

        it 'redirects to the manage mission page' do
          post_duplicate_new
          assert_redirected_to '/bureau_consultant/statement_of_activities/manage_mission'
        end
      end
    end

    describe 'on the destroy activity action' do
      before { created_activities_with_expenses }

      describe 'when a SOA is in edition' do
        it 'redirects to the new action' do
          delete '/bureau_consultant/statement_of_activities/destroy_activity',
                 params: { activity_id: created_activities_with_expenses.first.id }

          assert_redirected_to '/bureau_consultant/statement_of_activities/new'
        end

        it 'destroys the activity' do
          assert_difference 'Goxygene::OfficeActivityReportLine.count', -1 do
            delete '/bureau_consultant/statement_of_activities/destroy_activity',
                   params: { activity_id: created_activities_with_expenses.first.id }

          end

          assert !Goxygene::OfficeActivityReportLine.exists?(created_activities_with_expenses.first.id)
        end
      end
    end

    describe 'on the destroy action' do
      before { create_fresh_soa }

      describe 'when a SOA is in edition' do
        it 'redirects to the first time da action' do
          delete '/bureau_consultant/statement_of_activities'

          assert_redirected_to '/bureau_consultant/statement_of_activities/first_time_da'
        end

        it 'destroys the SOA in edition' do
          current_soa

          assert_difference 'Goxygene::OfficeActivityReport.count', -1 do
            delete '/bureau_consultant/statement_of_activities'
          end

          assert !Goxygene::OfficeActivityReport.exists?(current_soa.id)
        end

        describe 'with some activities filled' do
          before { created_activities_with_expenses }

          it 'cascade destroy the activities' do
            assert_difference 'Goxygene::OfficeActivityReportLine.count', created_activities_with_expenses.count * -1 do
              delete '/bureau_consultant/statement_of_activities'
            end
          end
        end
      end
    end

    describe 'on the update activity day action' do
      before do
        create_fresh_soa

        Rails.cache.clear
        Accountancy = Minitest::Mock.new
        Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
      end

      def post_activity_day(attrs: {}, line_id: nil)
        post '/bureau_consultant/statement_of_activities/update_activity_day', params: {
              date:    activity_date.strftime('%Y-%m-%d'),
              line_id: line_id,
              office_activity_report_line: {
                activity_type_id: activity_type.id,
                label:            label,
                time_span:        time_span,
              }.merge(attrs)
            }
      end

      describe 'when a SOA is in edition' do

        describe 'when creating a new entry' do
          describe 'when entry is valid' do

            describe 'when dont_have_holiday_bonus is false' do
              before do
                current_soa.consultant.update dont_have_holiday_bonus: false
              end

              it 'sets the right standard_gross_wage' do
                post_activity_day

                assert_equal ( 7 * time_span * current_soa.reload.payroll_contract_type&.base_to_row_coefficient * 10 ).round(2) ,
                             current_soa.reload.standard_gross_wage
              end

              it 'creates the activity' do
                assert_difference 'Goxygene::OfficeActivityReportLine.count' do
                  post_activity_day
                end

                last_line = Goxygene::OfficeActivityReportLine.last

                assert_equal activity_type.id, last_line.activity_type_id
                assert_equal time_span,        last_line.time_span
                assert_equal label,            last_line.label
              end

              it 'redirects to the new action' do
                post_activity_day
                assert_redirected_to '/bureau_consultant/statement_of_activities/new'
              end

              it 'reloads cumuls for the consultant' do
                post_activity_day

                assert_mock Accountancy
              end
            end

            it 'creates the activity' do
              assert_difference 'Goxygene::OfficeActivityReportLine.count' do
                post_activity_day
              end

              last_line = Goxygene::OfficeActivityReportLine.last

              assert_equal activity_type.id, last_line.activity_type_id
              assert_equal time_span,        last_line.time_span
              assert_equal label,            last_line.label
            end

            it 'redirects to the new action' do
              post_activity_day
              assert_redirected_to '/bureau_consultant/statement_of_activities/new'
            end

            it 'reloads cumuls for the consultant' do
              post_activity_day

              assert_mock Accountancy
            end
          end

          describe 'when the total for current day is higher than 1 day' do
            before { existing_entry }

            it 'does not create the activity' do
              assert_no_difference 'Goxygene::OfficeActivityReportLine.count' do
                post_activity_day attrs: { time_span: 0.5 }
              end
            end

            it 'renders the page' do
              post_activity_day attrs: { time_span: 0.5 }
              assert_response :success
            end

            it 'renders an error message' do
              post_activity_day attrs: { time_span: 0.5 }
              assert_select 'div#error_explanation ul li'
            end

            it 'does not render a translation error message' do
              post_activity_day attrs: { time_span: 0.5 }
              css_select('div#error_explanation ul li').each do |element|
                assert element.content.to_s.match("translation missing").nil?
              end
            end
          end

          describe 'when label is missing' do
            it 'does not create the activity' do
              assert_no_difference 'Goxygene::OfficeActivityReportLine.count' do
                post_activity_day attrs: { label: '' }
              end
            end

            it 'renders an error message' do
              post_activity_day attrs: { label: '' }
              assert_response :success
            end
          end

          describe 'when duration is missing' do
            it 'does not create the activity' do
              assert_no_difference 'Goxygene::OfficeActivityReportLine.count' do
                post_activity_day attrs: { time_span: '' }
              end
            end

            it 'renders the page' do
              post_activity_day attrs: { time_span: '' }
              assert_response :success
            end

            it 'renders an error message' do
              post_activity_day attrs: { time_span: '' }
              assert_select 'div#error_explanation ul li', 'Temps travaillé doit être rempli(e)'
            end
          end
        end

        describe 'when updating an existing entry' do
          before { existing_entry }

          describe 'when entry is valid' do
            describe 'when dont_have_holiday_bonus is false' do
              before do
                current_soa.consultant.update dont_have_holiday_bonus: false
              end

              it 'sets the right standard_gross_wage' do
                post_activity_day line_id: existing_entry.id,
                                  attrs: {
                                    label:            label,
                                    time_span:        time_span,
                                    activity_type_id: activity_type.id
                                  }

                assert_equal ( 7 * time_span * current_soa.reload.payroll_contract_type&.base_to_row_coefficient * 10 ).round(2) ,
                             current_soa.reload.standard_gross_wage
              end

              it 'does not create a new activity' do
                assert_no_difference 'Goxygene::OfficeActivityReportLine.count' do
                  post_activity_day line_id: existing_entry.id,
                                    attrs: {
                                      label:            label,
                                      time_span:        time_span,
                                      activity_type_id: activity_type.id
                                    }
                end

                last_line = Goxygene::OfficeActivityReportLine.last

                assert_equal activity_type.id, last_line.activity_type_id
                assert_equal time_span,        last_line.time_span
                assert_equal label,            last_line.label
              end

              it 'redirects to the new action' do
                post_activity_day line_id: existing_entry.id,
                                  attrs: {
                                    label:            label,
                                    time_span:        time_span,
                                    activity_type_id: activity_type.id
                                  }

                assert_redirected_to '/bureau_consultant/statement_of_activities/new'
              end

              it 'reloads cumuls for the consultant' do
                post_activity_day line_id: existing_entry.id,
                                  attrs: {
                                    label:            label,
                                    time_span:        time_span,
                                    activity_type_id: activity_type.id
                                  }

                assert_mock Accountancy
              end
            end

            it 'does not create a new activity' do
              assert_no_difference 'Goxygene::OfficeActivityReportLine.count' do
                post_activity_day line_id: existing_entry.id,
                                  attrs: {
                                    label:            label,
                                    time_span:        time_span,
                                    activity_type_id: activity_type.id
                                  }
              end
            end

            it 'updates the activity' do
              post_activity_day line_id: existing_entry.id,
                                attrs: {
                                  label:            label,
                                  time_span:        time_span,
                                  activity_type_id: activity_type.id
                                }

              assert_equal activity_type.id, existing_entry.reload.activity_type_id
              assert_equal time_span,        existing_entry.reload.time_span
              assert_equal label,            existing_entry.reload.label
            end

            it 'redirects to the new action' do
              post_activity_day line_id: existing_entry.id,
                                attrs: {
                                  label:            label,
                                  time_span:        time_span,
                                  activity_type_id: activity_type.id
                                }

              assert_redirected_to '/bureau_consultant/statement_of_activities/new'
            end

            it 'reloads cumuls for the consultant' do
              post_activity_day line_id: existing_entry.id,
                                attrs: {
                                  label:            label,
                                  time_span:        time_span,
                                  activity_type_id: activity_type.id
                                }

              assert_mock Accountancy
            end
          end

          describe 'when the total for current day is higher than 1 day' do
            before do
              current_soa.office_activity_report_lines.create!(
                activity_type: Goxygene::ActivityType.mission_or_development.active.shuffle.first,
                time_span:     0.25,
                label:         FFaker::Lorem.words(5).join(' '),
                date:          activity_date,
                created_by:    cas_authentications(:jackie_denesik).cas_user.id,
                updated_by:    cas_authentications(:jackie_denesik).cas_user.id
              )
            end

            it 'does not updates the activity' do
              post_activity_day line_id: existing_entry.id, attrs: { time_span: 1 }

              assert_not_equal 1,     existing_entry.reload.time_span
              assert_not_equal label, existing_entry.reload.label
            end

            it 'renders an error message' do
              post_activity_day line_id: existing_entry.id, attrs: { time_span: 1 }

              assert_response :success
            end
          end

          describe 'when label is missing' do
            it 'does not updates the activity' do
              post_activity_day line_id: existing_entry.id, attrs: { label: '' }

              assert_not_equal '', existing_entry.reload.label
            end

            it 'renders an error message' do
              post_activity_day line_id: existing_entry.id, attrs: { label: '' }

              assert_response :success
            end
          end

          describe 'when duration is missing' do
            it 'does not updates the activity' do
              post_activity_day line_id: existing_entry.id, attrs: { time_span: '' }

              assert_not_equal '', existing_entry.reload.label
            end

            it 'renders an error message' do
              post_activity_day line_id: existing_entry.id, attrs: { time_span: '' }

              assert_response :success
            end
          end
        end
      end

      describe 'when a SOA has its activities validated' do
        before do
          current_soa.update! consultant_comment: 'preventing auto-acceptance'
          current_soa.submit! :activities
        end

        it 'redirects to the manage mission page' do
          post_activity_day
          assert_redirected_to '/bureau_consultant/statement_of_activities/manage_mission'
        end
      end
    end

    describe 'on the update activity day on manage mission' do
      before do
        create_fresh_soa

        Rails.cache.clear
        Accountancy = Minitest::Mock.new
        Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
      end

      def post_activity_day_on_manage_mission(attrs = {})
        post '/bureau_consultant/statement_of_activities/update_activity_day_on_manage_mission', params: {
              office_activity_report_line: {
                activity_type_id: activity_type.id,
                label:            label,
                time_span:        time_span,
                date:             activity_date.strftime('%Y-%m-%d')
              }.merge(attrs)
            }
      end

      describe 'when a SOA is in edition' do

        describe 'when creating a new entry' do
          describe 'when entry is valid' do
            it 'creates the activity' do
              assert_difference 'Goxygene::OfficeActivityReportLine.count' do
                post_activity_day_on_manage_mission
              end

              last_line = Goxygene::OfficeActivityReportLine.last

              assert_equal activity_type.id, last_line.activity_type_id
              assert_equal time_span,        last_line.time_span
              assert_equal label,            last_line.label
            end

            it 'redirects to the new action' do
              post_activity_day_on_manage_mission
              assert_redirected_to '/bureau_consultant/statement_of_activities/manage_mission'
            end

            it 'reloads cumuls for the consultant' do
              post_activity_day_on_manage_mission

              assert_mock Accountancy
            end
          end

          describe 'when the total for current day is higher than 1 day' do
            before { existing_entry }

            it 'does not create the activity' do
              assert_no_difference 'Goxygene::OfficeActivityReportLine.count' do
                post_activity_day_on_manage_mission time_span: 0.5
              end
            end

            it 'renders an error message' do
              post_activity_day_on_manage_mission time_span: 0.5
              assert_response :success
            end
          end

          describe 'when label is missing' do
            it 'does not create the activity' do
              assert_no_difference 'Goxygene::OfficeActivityReportLine.count' do
                post_activity_day_on_manage_mission label: ''
              end
            end

            it 'renders an error message' do
              post_activity_day_on_manage_mission label: ''
              assert_response :success
            end
          end

          describe 'when duration is missing' do
            it 'does not create the activity' do
              assert_no_difference 'Goxygene::OfficeActivityReportLine.count' do
                post_activity_day_on_manage_mission time_span: ''
              end
            end

            it 'renders an error message' do
              post_activity_day_on_manage_mission time_span: ''
              assert_response :success
            end
          end
        end
      end

      describe 'when a SOA has its activities validated' do
        before do
          current_soa.update! consultant_comment: 'preventing auto-acceptance'
          current_soa.submit! :activities
        end

        it 'redirects to the manage mission page' do
          post_activity_day_on_manage_mission
          assert_redirected_to '/bureau_consultant/statement_of_activities/manage_mission'
        end
      end
    end

    describe 'on the manage activity day action' do
      before { create_fresh_soa }

      describe 'when a SOA is in edition' do
        before do
          get '/bureau_consultant/statement_of_activities/manage_activity_day', params: {
            date: (current_soa.date + 5.days).strftime('%Y-%m-%d')
          }
        end

        it 'renders the page' do
          assert_response :success
        end

        it 'does not include inactive types' do
          total_active_activity_types = Goxygene::ActivityType.mission_or_development.active.count
          total_active_activity_types -= 1 unless consultant.c_pro_type?
          assert_select "#office_activity_report_line_activity_type_id option", total_active_activity_types

          css_select("#office_activity_report_line_activity_type_id option").each do |entry|
            entry_id = entry.attributes['value'].value
            assert Goxygene::ActivityType.find(entry_id).active
          end
        end
      end

      describe 'when a SOA has its activities validated' do
        before do
          current_soa.update! consultant_comment: 'preventing auto-acceptance'
          current_soa.submit! :activities
        end

        it 'redirects to the manage mission page' do
          get '/bureau_consultant/statement_of_activities/manage_activity_day', params: {
            date: (current_soa.date + 5.days).strftime('%Y-%m-%d')
          }

          assert_redirected_to '/bureau_consultant/statement_of_activities/manage_mission'
        end
      end
    end

    describe 'on the first_time_new action' do
      before { create_fresh_soa }

      describe 'when a SOA is in edition' do
        it 'renders the page' do
          get '/bureau_consultant/statement_of_activities/first_time_new'

          assert_response :success
        end
      end

      describe 'when a SOA is over DSN office date' do
        before do
          current_soa.update_columns month: 10
          current_soa.reload
        end

        it 'redirects to ...' do
          get '/bureau_consultant/statement_of_activities/first_time_new'

          assert_redirected_to '/bureau_consultant/statement_of_activities'
        end

        it 'set the opened SOA as rejected' do
          soa_id = current_soa.id

          get '/bureau_consultant/statement_of_activities/first_time_new'

          assert_equal 'rejected', consultant.office_activity_reports.find(soa_id).activity_report_status
        end
      end

      describe 'when a SOA has its activities validated' do
        before do
          current_soa.update! consultant_comment: 'preventing auto-acceptance'
          current_soa.submit! :activities
        end

        it 'redirects to the manage mission page' do
          get '/bureau_consultant/statement_of_activities/first_time_new'

          assert_redirected_to '/bureau_consultant/statement_of_activities/manage_mission'
        end
      end
    end

    describe 'on the create_previous_empty action' do
      before { consultant.office_activity_reports.in_edition.destroy_all }

      let(:soa_to_create_count) { Date.current.month - consultant.office_activity_reports.where(year: Date.current.year).count - 1 }

      it 'creates all the previous DDAs' do
        assert_difference 'Goxygene::OfficeActivityReport.count', soa_to_create_count do
          post '/bureau_consultant/statement_of_activities/create_previous_empty'
        end
      end

      it 'responds with ok' do
        post '/bureau_consultant/statement_of_activities/create_previous_empty'

        assert_response :ok
      end

      it 'sets their status to completed' do
        post '/bureau_consultant/statement_of_activities/create_previous_empty'

        soa = Goxygene::OfficeActivityReport.last

        assert_equal 'completed', soa.activity_report_status
        assert_equal 'completed', soa.activity_report_expense_status
      end

      it 'creates the matching DA' do
        assert_difference 'Goxygene::ActivityReport.count', soa_to_create_count do
          post '/bureau_consultant/statement_of_activities/create_previous_empty'
        end
      end

      it 'sets the matching DA status to completed' do
        post '/bureau_consultant/statement_of_activities/create_previous_empty'

        soa = Goxygene::OfficeActivityReport.last

        assert_equal 'completed', soa.activity_report.activity_report_status
        assert_equal 'completed', soa.activity_report.activity_report_expense_status
      end


    end

    describe 'on the create action' do
      let(:date) { consultant.first_possible_statement_of_activities_request_month }

      before { consultant.office_activity_reports.in_edition.destroy_all }

      describe 'with no activity' do
        it 'creates an activity with the right date' do
          assert_difference 'Goxygene::OfficeActivityReport.count' do
            post '/bureau_consultant/statement_of_activities', params: {
              statement_of_activities_request: {
                date: date.strftime('%Y-%m-%d'),
                no_activity: "true"
              }
            }

            assert_equal date, Goxygene::OfficeActivityReport.last.date
          end
        end

        it 'validates the SOA' do
          post '/bureau_consultant/statement_of_activities', params: {
            statement_of_activities_request: {
              date: date.strftime('%Y-%m-%d'),
              no_activity: "true"
            }
          }

          assert_equal 'completed', Goxygene::OfficeActivityReport.last.activity_report_status
          assert_equal 'completed', Goxygene::OfficeActivityReport.last.activity_report_expense_status
        end

        it 'redirects to the history page' do
          post '/bureau_consultant/statement_of_activities', params: {
            statement_of_activities_request: {
              date: date.strftime('%Y-%m-%d'),
              no_activity: "true"
            }
          }

          assert_redirected_to '/bureau_consultant/statement_of_activities_requests/history'
        end

      end

      describe 'with an activity' do
        it 'creates an activity with the right date' do
          assert_difference 'Goxygene::OfficeActivityReport.count' do
            post '/bureau_consultant/statement_of_activities', params: {
              statement_of_activities_request: {
                date: date.strftime('%Y-%m-%d'),
                no_activity: "false"
              }
            }

            assert_equal date, Goxygene::OfficeActivityReport.last.date
          end
        end

        it 'redirects to the first time new action' do
          post '/bureau_consultant/statement_of_activities', params: {
            statement_of_activities_request: {
              date: date.strftime('%Y-%m-%d'),
              no_activity: "false"
            }
          }

          assert_redirected_to '/bureau_consultant/statement_of_activities/first_time_new'
        end

        it 'sets the kilometer_count_trace' do
          post '/bureau_consultant/statement_of_activities', params: {
            statement_of_activities_request: {
              date: date.strftime('%Y-%m-%d'),
              no_activity: "false"
            }
          }

          assert_not_nil Goxygene::OfficeActivityReport.last.kilometer_count_trace
        end
      end
    end

    describe 'on the manage mission action' do
      describe 'if consultant cannot get refund on expenses' do
        before { consultant.update! granted_expenses: false }

        it 'redirects to the synthesis 3 step action' do
          get '/bureau_consultant/statement_of_activities/manage_mission'
          assert_redirected_to '/bureau_consultant/statement_of_activities/synthesis_3_step'
        end
      end
    end

    describe 'on the new action' do
      before do
        create_fresh_soa
      end

      describe 'when a SOA is over DSN office date' do
        before do
          current_soa.update_columns month: 10
          current_soa.reload
        end

        it 'redirects to ...' do
          get '/bureau_consultant/statement_of_activities/first_time_new'

          assert_redirected_to '/bureau_consultant/statement_of_activities'
        end

        it 'set the opened SOA as rejected' do
          soa_id = current_soa.id

          get '/bureau_consultant/statement_of_activities/first_time_new'

          assert_equal 'rejected', consultant.office_activity_reports.find(soa_id).activity_report_status
        end
      end

      describe 'when activities have been validated' do
        before do
          current_soa.reload.update! activity_report_status:         :pending,
                                     activity_report_expense_status: :office_editing
        end

        it 'redirects to the expenses edition page' do
          get '/bureau_consultant/statement_of_activities/new'

          assert_redirected_to '/bureau_consultant/statement_of_activities/manage_mission'
        end
      end

      describe 'when the SOA has no lines (empty)' do
        before do
          current_soa.office_activity_report_lines.destroy_all
        end

        it 'redirects to the first time new action' do
          get '/bureau_consultant/statement_of_activities/new'

          assert_redirected_to '/bureau_consultant/statement_of_activities/first_time_new'
        end
      end

      describe 'when SOA is in edition and already have some lines' do
        before { created_activities_with_expenses }

        it 'renders the page' do
          get '/bureau_consultant/statement_of_activities/new'

          assert_response :success
        end
      end

      describe 'when no statement of activities is currently in edition' do
        it 'redirects to the first time da action' do
          current_soa.destroy if current_soa

          get '/bureau_consultant/statement_of_activities/new'

          assert_redirected_to '/bureau_consultant/statement_of_activities/first_time_da'
        end
      end
    end

    describe 'on the first time da action' do
      describe 'when no statement of activities is currently in edition' do
        describe 'when a new statement of activities is possible' do
          before do
            consultant.office_activity_reports.in_edition.destroy_all

            Rails.cache.clear

            Accountancy = Minitest::Mock.new
            Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
          end

          it 'renders the page' do
            get '/bureau_consultant/statement_of_activities/first_time_da'
            assert_response :success
          end

          it 'displays a selection of available months' do
            get '/bureau_consultant/statement_of_activities/first_time_da'

            assert_select 'select#statement_of_activities_request_date'
            css_select('select#statement_of_activities_request_date option').each do |option|
              assert_equal consultant.first_possible_statement_of_activities_request_month, Date.parse(option['value'])
            end
          end

          describe 'with no prior salary' do
            before do
              consultant.activity_reports.update_all wage_id: nil
              consultant.wages.destroy_all
              consultant.office_activity_reports.destroy_all
            end

            it 'renders the page' do
              get '/bureau_consultant/statement_of_activities/first_time_da'
              assert_response :success
            end

          end
        end

        describe 'when a new statement of activities is not possible' do
          it 'redirects to the wait page'
        end
      end

      describe 'when a statement of activities is currently in edition' do
        it 'redirects to the new action' do
          # checks if the consultant has a statement of activities in edition
          assert !!current_soa

          get '/bureau_consultant/statement_of_activities/first_time_da'

          assert_redirected_to '/bureau_consultant/statement_of_activities/new'
        end
      end
    end

    describe 'on the wait_for_validate page' do

      let(:workbook) { RubyXL::Parser.parse_buffer(response.body) }

      it 'renders the page' do
        get '/bureau_consultant/statement_of_activities/wait_for_validate'

        assert_response :success
      end
    end

    describe 'on the index page' do
      it 'redirects to the first time da action' do
        get '/bureau_consultant/statement_of_activities'
        assert_redirected_to '/bureau_consultant/statement_of_activities/first_time_da'
      end
    end

    describe 'on the history page' do

      let(:default_filter_date_lower_bound)  { 1.year.ago.beginning_of_year.to_date }
      let(:default_filter_date_higher_bound) { Date.current.end_of_year + 6.months  }
      let(:filter_date_lower_bound)          { 2.year.ago.beginning_of_year.to_date }
      let(:filter_date_higher_bound)         { 6.months.ago.to_date                 }

      it 'displays the statement of activities history page' do
        get '/bureau_consultant/statement_of_activities/history'
        assert_response :success
      end

      it 'displays SOAs within the default date range' do
        get '/bureau_consultant/statement_of_activities/history'

        # check for the filter form values
        assert_ransack_filter :date_without_day_gteq, default_filter_date_lower_bound .strftime('%m/%Y')
        assert_ransack_filter :date_without_day_lteq, default_filter_date_higher_bound.strftime('%m/%Y')

        # check if each entry is within the date range
        css_select("tr.statement_of_activities").each do |entry|
          entry_date = Date.new(entry.css("td.statement_of_activity_year").first.content.to_i,
                                I18n.t("date.month_names").find_index(entry.css("td.statement_of_activity_month").first.content.downcase))
          assert entry_date >= default_filter_date_lower_bound
          assert entry_date <= default_filter_date_higher_bound
        end
      end

      it 'can filter by creation date' do
        get '/bureau_consultant/statement_of_activities/history',
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
        css_select("tr.statement_of_activities").each do |entry|
          entry_date = Date.new(entry.css("td.statement_of_activity_year").first.content.to_i,
                                I18n.t("date.month_names").find_index(entry.css("td.statement_of_activity_month").first.content.downcase))
          assert entry_date >= filter_date_lower_bound
          assert entry_date <= filter_date_higher_bound
        end
      end

      it 'sorts asc by year' do
        get '/bureau_consultant/statement_of_activities/history',
            params: {
              q: {
                s: 'year asc',
                date_without_day_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_without_day_lteq: filter_date_higher_bound.strftime('%m/%Y')
              }
            }

        assert_tabledata_order(selector: 'tr.statement_of_activities',
                               field: 'statement_of_activity_year') { |entry, previous|

          previous.content.to_i <= entry.content.to_i

        }
      end

      it 'sorts desc by year' do
        get '/bureau_consultant/statement_of_activities/history',
            params: {
              q: {
                s: 'year desc',
                date_without_day_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_without_day_lteq: filter_date_higher_bound.strftime('%m/%Y')
              }
            }

        assert_tabledata_order(selector: 'tr.statement_of_activities',
                               field: 'statement_of_activity_year') { |entry, previous|

          previous.content.to_i >= entry.content.to_i

        }
      end

      it 'sorts asc by month' do
        get '/bureau_consultant/statement_of_activities/history',
            params: {
              q: {
                s: 'month asc',
                date_without_day_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_without_day_lteq: filter_date_higher_bound.strftime('%m/%Y')
              }
            }

        assert_tabledata_order(selector: 'tr.statement_of_activities',
                               field: 'statement_of_activity_month') { |entry, previous|

          I18n.t("date.month_names").find_index(previous.content.downcase) <= I18n.t("date.month_names").find_index(entry.content.downcase)

        }
      end

      it 'sorts desc by month' do
        get '/bureau_consultant/statement_of_activities/history',
            params: {
              q: {
                s: 'month desc',
                date_without_day_gteq: filter_date_lower_bound.strftime('%m/%Y'),
                date_without_day_lteq: filter_date_higher_bound.strftime('%m/%Y')
              }
            }

        assert_tabledata_order(selector: 'tr.statement_of_activities',
                               field: 'statement_of_activity_month') { |entry, previous|

          I18n.t("date.month_names").find_index(previous.content.downcase) >= I18n.t("date.month_names").find_index(entry.content.downcase)

        }
      end
    end

    describe 'on the export page' do
      let(:workbook) { RubyXL::Parser.parse_buffer(response.body) }

      before do
        get '/bureau_consultant/statement_of_activities/history/export.xlsx',
            params: {
              q: {
                id_in: consultant.activity_report_ids,
                date_without_day_gteq: 10.years.ago.strftime('%m/%Y'),
                date_without_day_lteq: 10.years.from_now.strftime('%m/%Y')
              }
            }
      end

      it 'responds with success' do
        assert_response :success
      end

      it 'translates the status' do
        assert_equal "Validée", workbook[0][1][9].value
      end

      it 'does not format the number of days' do
        assert workbook[0][1][2].value.is_a? Float
      end

      it 'does not format the number of hours' do
        assert workbook[0][1][3].value.is_a? Float
      end

      it 'does not format the gross wage' do
        assert workbook[0][1][6].value.is_a? Float
      end

      it 'does not format the amount of expenses' do
        assert workbook[0][1][7].value.is_a? Float
      end

      it 'does not format the amount of KMs' do
        assert workbook[0][1][8].value.is_a?(Float) || workbook[0][1][8].value.is_a?(Integer)
      end

    end
  end

  describe 'not authenticated' do
    describe 'on the first time new action' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/statement_of_activities/first_time_new'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end

    describe 'on the first time da action' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/statement_of_activities/first_time_da'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end

    describe 'on the new action' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/statement_of_activities/new'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end

    describe 'on the index page' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/statement_of_activities'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end

    describe 'on the history page' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/statement_of_activities/history'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end
  end
end

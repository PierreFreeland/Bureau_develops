require 'test_helper'

describe 'BureauConsultant::AdvancesController' do
  describe 'authenticated as a consultant' do

    before { sign_in cas_authentications(:jackie_denesik) }

    let(:consultant)   { Goxygene::Consultant.find 9392   }
    let(:amount)       { 250 + rand(250)                  }
    let(:comment)      { FFaker::Lorem.words(5).join(' ') }
    let(:last_advance) { consultant.wage_advances.last    }
    let(:balances)          { OpenStruct.new id: consultant.id, cash: 9999.0, activity: 0.0, invoicing: 0.0 }
    let(:negative_balances) { OpenStruct.new id: consultant.id, cash: -9999.0, activity: 0.0, invoicing: 0.0 }

    describe 'on mobile' do

      describe 'on the history page' do

        it 'displays the advances history page' do
          get '/m/bureau_consultant/advances/history'
          assert_response :success
        end

      end

      describe 'on the new wage advance page' do

        before do
          Rails.cache.clear
          Accountancy = Minitest::Mock.new
          Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
        end

        it 'displays the new wage advance page' do
          get '/m/bureau_consultant/advances/new'

          assert_response :success
        end

        it 'calls the Accountancy API to fetch the max amount' do
          get '/m/bureau_consultant/advances/new'

          assert_mock Accountancy
        end

        it 'shows the maximum allowed amount' do
          get '/m/bureau_consultant/advances/new'

          assert_select "span#amount_maximum[data-value=\"8725.41\"]"
        end

        it 'shows 0 when the max allowed amount is under 0' do
          Accountancy = Minitest::Mock.new
          Accountancy.expect(:consultant_account_balances, negative_balances, [consultant.id, environment: "FREELAND", clear_cache: true])

          get '/m/bureau_consultant/advances/new'

          assert_select 'span#amount_maximum[data-value="0.0"]'
        end

        it 'shows an amount input' do
          get '/m/bureau_consultant/advances/new'

          assert_select 'form#advance-form' do
            assert_select 'input#advance_amount'
          end
        end

        it 'shows a comment input' do
          get '/m/bureau_consultant/advances/new'

          assert_select 'form#advance-form' do
            assert_select 'textarea#advance_comment'
          end
        end
      end

      describe 'when submitting a new wage advance request' do
        before do
          Rails.cache.clear
          Accountancy = Minitest::Mock.new
          Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
        end

        def post_create_advance(attrs = {})
          post '/m/bureau_consultant/advances', params: {
            wage_advance: {
              amount: amount,
              correspondant_comment: comment
            }.merge(attrs)
          }
        end

        it 'creates an advance request in database' do
          assert_difference 'Goxygene::WageAdvance.count' do
            post_create_advance
          end
        end

        it 'sets the right created_by' do
          post_create_advance

          assert_equal consultant.individual_id, last_advance.created_by
        end

        it 'sets the right updated_by' do
          post_create_advance

          assert_equal consultant.individual_id, last_advance.updated_by
        end

        it 'sets the amount' do
          post_create_advance

          assert_equal amount, last_advance.amount
        end

        it 'sets the comment' do
          post_create_advance

          assert_equal comment, last_advance.correspondant_comment
        end

        it 'sets the status' do
          post_create_advance

          assert_equal 'itg_editing', last_advance.wage_advance_status
        end

        it 'sets the date' do
          post_create_advance

          assert_equal Date.current, last_advance.date.try(:to_date)
        end

        it 'sets the consultant_validation timestamp' do
          skip "there is no consultant_validation on the advances"

          post_create_advance

          assert ((Time.now.to_i - 10)..(Time.now.to_i + 10)).include? last_advance.consultant_validation.to_i
        end

        it 'redirects to the history page' do
          post_create_advance

          assert_redirected_to '/m/bureau_consultant/advances/history'
        end

        it 'changes the maximum amount allowed' do
          old_amount = consultant.cumuls.estimate_max_advance

          post_create_advance

          assert old_amount != consultant.reload.cumuls.estimate_max_advance
        end

        it 'refuses non numeric amount' do
          assert_no_difference 'Goxygene::WageAdvance.count' do
            post_create_advance amount: 'meh'
          end

          assert_response :success # renders new
        end

        it 'refuses negative amount' do
          assert_no_difference 'Goxygene::WageAdvance.count' do
            post_create_advance amount: -500
          end

          assert_response :success # renders new
        end

        it 'refuses amount equal to zero' do
          assert_no_difference 'Goxygene::WageAdvance.count' do
            post_create_advance amount: 0
          end

          assert_response :success # renders new
        end

        describe 'when amount is higher than the maximum allowed' do
          it 'does not create anything in database' do
            assert_no_difference 'Goxygene::WageAdvance.count' do
              post '/m/bureau_consultant/advances', params: { wage_advance: { amount: balances.cash + 1 } }
            end
          end

          it 'renders an error message' do
            post '/m/bureau_consultant/advances', params: { wage_advance: { amount: balances.cash + 1 } }

            assert_select 'label.error-message[for="wage_advance_amount"]'
          end

          it 'responds with success' do
            post '/m/bureau_consultant/advances', params: { wage_advance: { amount: balances.cash + 1 } }

            assert_response :success
          end

          it 'does not display a translation error' do
            post '/m/bureau_consultant/advances', params: { wage_advance: { amount: balances.cash + 1 } }

            message = css_select('label.error-message[for="wage_advance_amount"]').text

            assert_no_match /translation missing/, message
          end
        end

        it 'refuses an amount when max allowed is zero' do
          Accountancy = Minitest::Mock.new
          Accountancy.expect(:consultant_account_balances, negative_balances, [consultant.id, environment: "FREELAND", clear_cache: true])

          assert_no_difference 'Goxygene::WageAdvance.count' do
            post '/m/bureau_consultant/advances', params: { wage_advance: { amount: rand(999) } }
          end

          assert_response :success # renders new
        end
      end

    end

    describe 'on the new wage advance page' do

      before do
        Rails.cache.clear
        Accountancy = Minitest::Mock.new
        Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
      end

      it 'displays the new wage advance page' do
        get '/bureau_consultant/advances/new'

        assert_response :success
      end

      it 'calls the Accountancy API to fetch the max amount' do
        get '/bureau_consultant/advances/new'

        assert_mock Accountancy
      end

      it 'shows the maximum allowed amount' do
        get '/bureau_consultant/advances/new'

        assert_select "span#amount_maximum[data-value=\"8725.41\"]"
      end

      it 'shows 0 when the max allowed amount is under 0' do
        Accountancy = Minitest::Mock.new
        Accountancy.expect(:consultant_account_balances, negative_balances, [consultant.id, environment: "FREELAND", clear_cache: true])

        get '/bureau_consultant/advances/new'

        assert_select 'span#amount_maximum[data-value="0.0"]'
      end

      it 'shows an amount input' do
        get '/bureau_consultant/advances/new'

        assert_select 'form#advance-form' do
          assert_select 'input#advance_amount'
        end
      end

      it 'shows a comment input' do
        get '/bureau_consultant/advances/new'

        assert_select 'form#advance-form' do
          assert_select 'textarea#advance_comment'
        end
      end
    end

    describe 'when submitting a new wage advance request' do
      before do
        Rails.cache.clear
        Accountancy = Minitest::Mock.new
        Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
      end

      def post_create_advance(attrs = {})
        post '/bureau_consultant/advances', params: {
          wage_advance: {
            amount: amount,
            correspondant_comment: comment
          }.merge(attrs)
        }
      end

      it 'creates an advance request in database' do
        assert_difference 'Goxygene::WageAdvance.count' do
          post_create_advance
        end
      end

      it 'sets the amount' do
        post_create_advance

        assert_equal amount, last_advance.amount
      end

      it 'sets the comment' do
        post_create_advance

        assert_equal comment, last_advance.correspondant_comment
      end

      it 'sets the status' do
        post_create_advance

        assert_equal 'itg_editing', last_advance.wage_advance_status
      end

      it 'sets the date' do
        post_create_advance

        assert_equal Date.current, last_advance.date.try(:to_date)
      end

      it 'sets the consultant_validation timestamp' do
        skip "there is no consultant_validation on the advances"

        post_create_advance

        assert ((Time.now.to_i - 10)..(Time.now.to_i + 10)).include? last_advance.consultant_validation.to_i
      end

      it 'redirects to the history page' do
        post_create_advance

        assert_redirected_to '/bureau_consultant/advances/history'
      end

      it 'changes the maximum amount allowed' do
        old_amount = consultant.cumuls.estimate_max_advance

        post_create_advance

        assert old_amount != consultant.reload.cumuls.estimate_max_advance
      end

      it 'refuses non numeric amount' do
        assert_no_difference 'Goxygene::WageAdvance.count' do
          post_create_advance amount: 'meh'
        end

        assert_response :success # renders new
      end

      it 'refuses negative amount' do
        assert_no_difference 'Goxygene::WageAdvance.count' do
          post_create_advance amount: -500
        end

        assert_response :success # renders new
      end

      it 'refuses amount equal to zero' do
        assert_no_difference 'Goxygene::WageAdvance.count' do
          post_create_advance amount: 0
        end

        assert_response :success # renders new
      end

      describe 'when amount is higher than the maximum allowed' do
        it 'does not create anything in database' do
          assert_no_difference 'Goxygene::WageAdvance.count' do
            post '/bureau_consultant/advances', params: { wage_advance: { amount: balances.cash + 1 } }
          end
        end

        it 'renders an error message' do
          post '/bureau_consultant/advances', params: { wage_advance: { amount: balances.cash + 1 } }

          assert_select 'label.error-message[for="wage_advance_amount"]'
        end

        it 'responds with success' do
          post '/bureau_consultant/advances', params: { wage_advance: { amount: balances.cash + 1 } }

          assert_response :success
        end

        it 'does not display a translation error' do
          post '/bureau_consultant/advances', params: { wage_advance: { amount: balances.cash + 1 } }

          message = css_select('label.error-message[for="wage_advance_amount"]').text

          assert_no_match /translation missing/, message
        end
      end

      it 'refuses an amount when max allowed is zero' do
        Accountancy = Minitest::Mock.new
        Accountancy.expect(:consultant_account_balances, negative_balances, [consultant.id, environment: "FREELAND", clear_cache: true])

        assert_no_difference 'Goxygene::WageAdvance.count' do
          post '/bureau_consultant/advances', params: { wage_advance: { amount: rand(999) } }
        end

        assert_response :success # renders new
      end
    end

    describe 'on the history page' do

      let(:default_filter_date_lower_bound)  { 1.year.ago.beginning_of_year.to_date }
      let(:default_filter_date_higher_bound) { Date.current.end_of_year + 6.months  }
      let(:filter_date_lower_bound)          { 2.year.ago.beginning_of_year.to_date }
      let(:filter_date_higher_bound)         { 6.months.ago.to_date                 }

      it 'displays the advances history page' do
        get '/bureau_consultant/advances/history'
        assert_response :success
      end

      it 'includes the advance status' do
        get '/bureau_consultant/advances/history'

        assert_select 'td.wage_advance_status'
        css_select('td.wage_advance_status').each { |entry| assert_equal 'Validée', entry.text }
      end

      it 'includes a checkbox for xls export' do
        get '/bureau_consultant/advances/history'

        assert_select 'input[type="checkbox"][name="q[id_in][]"]'
      end

      it 'displays wage advances within the default date range' do
        get '/bureau_consultant/advances/history'

        # check for the filter form values
        assert_ransack_filter :date_gteq, default_filter_date_lower_bound .strftime('%d/%m/%Y')
        assert_ransack_filter :date_lteq, default_filter_date_higher_bound.strftime('%d/%m/%Y')

        # check if each entry is within the date range
        assert_tabledata_value(selector: 'table.wage_advances tr.wage_advance',
                               field:    'wage_advance_date') { |entry|
          Date.parse(entry.content) > default_filter_date_lower_bound && \
          Date.parse(entry.content) < default_filter_date_higher_bound
        }
      end

      it 'can filter by creation date' do
        get '/bureau_consultant/advances/history',
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
        assert_tabledata_value(selector: 'table.wage_advances tr.wage_advance',
                               field:    'wage_advance_date') { |entry|
          Date.parse(entry.content) >= filter_date_lower_bound && \
          Date.parse(entry.content) <= filter_date_higher_bound
        }
      end

      it 'sorts asc by date' do
        get '/bureau_consultant/advances/history', params: { q: { s: 'date asc' } }

        assert_tabledata_order(selector: 'table.wage_advances tr.wage_advance',
                               field: 'wage_advance_date') { |entry, previous|

          Date.parse(previous.content) <= Date.parse(entry.content)

        }
      end

      it 'sorts desc by date' do
        get '/bureau_consultant/advances/history', params: { q: { s: 'date desc' } }

        assert_tabledata_order(selector: 'table.wage_advances tr.wage_advance',
                               field: 'wage_advance_date') { |entry, previous|

          Date.parse(previous.content) >= Date.parse(entry.content)

        }
      end

      it 'sorts asc by amount' do
        get '/bureau_consultant/advances/history', params: { q: { s: 'amount asc' } }

        assert_tabledata_order(selector: 'table.wage_advances tr.wage_advance',
                               field: 'wage_advance_amount') { |entry, previous|

          Float.parse_formated_currency(previous.content) <= Float.parse_formated_currency(entry.content)

        }
      end

      it 'sorts desc by amount' do
        get '/bureau_consultant/advances/history', params: { q: { s: 'amount desc' } }

        assert_tabledata_order(selector: 'table.wage_advances tr.wage_advance',
                               field: 'wage_advance_amount') { |entry, previous|

          Float.parse_formated_currency(previous.content) >= Float.parse_formated_currency(entry.content)

        }
      end
    end

    describe 'on the export page' do
      let(:workbook) { RubyXL::Parser.parse_buffer(response.body) }

      before do
        get '/bureau_consultant/advances/history/export.xlsx',
            params: { q: { id_in: consultant.wage_advance_ids } }
      end

      it 'responds with success' do
        assert_response :success
      end

      it 'translates the status' do
        assert_equal 'Fait', workbook[0][1][2].value
      end

      it 'does not format the amount' do
        assert workbook[0][1][1].value.is_a? Float
      end
    end
  end

  describe 'not authenticated' do
    describe 'when submitting a new wage advance request' do
      it 'does not create a new request in database' do
        assert_no_difference 'Goxygene::WageAdvance.count' do
          post '/bureau_consultant/advances', params: {
            wage_advance: {
              amount: 500,
              correspondant_comment: 'meh'
            }
          }
        end
      end

      it 'redirects to the authentication page' do
        post '/bureau_consultant/advances', params: {
          wage_advance: {
            amount: 500,
            correspondant_comment: 'meh'
          }
        }

        assert_redirected_to '/cas_authentications/sign_in'
      end
    end

    describe 'on the history page' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/advances/history'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end

    describe 'on the new wage advance page' do
      it 'redirects to the authentication page' do
        get '/bureau_consultant/advances/new'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end
  end
end

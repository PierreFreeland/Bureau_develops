require 'test_helper'

describe 'BureauConsultant::StatementOfOperatingExpensesRequestLinesController' do

  let(:consultant)   { Goxygene::Consultant.find 9392                        }
  let(:current_soo)  { consultant.office_operating_expenses.in_edition.first }
  let(:last_line)    { current_soo.office_operating_expense_lines.last       }
  let(:label)        { FFaker::Lorem.words(5).join(' ')                      }
  let(:date)         { current_soo.date + (rand 25).days                     }
  let(:total)        { 10 + rand(100).to_f                                   }
  let(:vat)          { Goxygene::Vat.active.find([5,7,11,12]).shuffle.first  }
  let(:vat_id)       { vat.id                                                }
  let(:expense_type) { Goxygene::ExpenseType.for_expenses.has_vat.shuffle.first }

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
      year:  Date.current.year,
      month: Date.current.month,
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

  def post_create_line(attrs = {})
    post '/bureau_consultant/statement_of_operating_expenses_request_lines', params: {
      office_operating_expense_line: {
        date:             date,
        label:            label,
        vat_id:           vat_id,
        expense_type_id:  expense_type.id,
        total_with_taxes: total
      }.merge(attrs)
    }
  end

  def patch_update_line(attrs: {}, line_id: nil)
    line_id ||= created_lines.last.id

    patch "/bureau_consultant/statement_of_operating_expenses_request_lines/#{line_id}", params: {
      office_operating_expense_line: {
        date:             date,
        label:            label,
        vat_id:           vat_id,
        expense_type_id:  expense_type.id,
        total_with_taxes: total
      }.merge(attrs)
    }
  end

  def delete_destroy_line(line_id: nil)
    line_id ||= created_lines.last.id

    delete "/bureau_consultant/statement_of_operating_expenses_request_lines/#{line_id}"
  end

  describe 'authenticated as a consultant' do

    before { sign_in cas_authentications(:jackie_denesik) }

    describe 'when the consultant has expenses reimbursed' do

      describe 'on the destroy action' do
        describe 'when a SOO is in edition' do
          before do
            created_lines
            current_soo.reload

            Rails.cache.clear
            Accountancy = Minitest::Mock.new
            Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
          end

          it 'destroys the line' do
            assert_difference 'Goxygene::OfficeOperatingExpenseLine.count', -1 do
              delete_destroy_line
            end
          end

          it 'does not destroy the OfficeOperatingExpenseTotal' do
            assert_no_difference 'Goxygene::OfficeOperatingExpenseTotal.count' do
              delete_destroy_line
            end
          end

          it 'updates the OfficeOperatingExpenseTotal' do
            line = created_lines.last

            previous_total = current_soo.office_operating_expense_totals.find_by(expense_type_id: line.expense_type_id).total

            delete_destroy_line line_id: line.id

            assert_not_equal previous_total, current_soo.office_operating_expense_totals.find_by(expense_type_id: line.expense_type_id).reload.total
          end

          it 'redirects to the SOO' do
            delete_destroy_line

            assert_redirected_to '/bureau_consultant/statement_of_operating_expenses/current'
          end

          it 'updates totals on SOO' do
            previous_total_with_taxes = current_soo.total_with_taxes
            previous_total            = current_soo.total

            line = created_lines.last

            previous_line_total_with_taxes = line.total_with_taxes
            previous_line_amount           = line.amount

            delete_destroy_line line_id: line.id

            new_total_with_taxes = previous_total_with_taxes - previous_line_total_with_taxes
            new_total            = previous_total            - previous_line_amount
            new_vat              = new_total_with_taxes - new_total

            assert_equal new_total_with_taxes, current_soo.reload.total_with_taxes
            assert_equal new_total,            current_soo.reload.total
            assert_equal new_vat,              current_soo.reload.vat
          end

          it 'reloads cumuls for the consultant' do
            delete_destroy_line

            assert_mock Accountancy
          end
        end

        describe 'when no SOO is curently in edition' do
          before do
            created_lines
            current_soo.submit!
          end

          it 'does not destroy the line' do
            assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
              delete_destroy_line
            end
          end

          it 'redirects to the new SOO page' do
            delete_destroy_line

            assert_redirected_to '/bureau_consultant/statement_of_operating_expenses/new'
          end
        end
      end

      describe 'on the update action' do
        describe 'when a SOO is in edition' do
          before do
            created_lines
            current_soo.reload

            Rails.cache.clear
            Accountancy = Minitest::Mock.new
            Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
          end

          describe 'when the line is valid' do
            it 'does not create a new line' do
              assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
                patch_update_line
              end
            end

            it 'sets the right values' do
              patch_update_line

              assert_equal date,         last_line.date
              assert_equal label,        last_line.label
              assert_equal total,        last_line.total_with_taxes
              assert_equal vat_id,       last_line.vat_id
              assert_equal expense_type, last_line.expense_type
            end

            it 'does not create new OfficeOperatingExpenseTotal entries' do
              assert_no_difference 'Goxygene::OfficeOperatingExpenseTotal.count' do
                patch_update_line
              end
            end

            it 'updates the OfficeOperatingExpenseTotal' do
              line = created_lines.last

              previous_total = current_soo.office_operating_expense_totals.find_by(expense_type_id: line.expense_type_id).total

              patch_update_line line_id: line.id

              assert_not_equal previous_total, current_soo.office_operating_expense_totals.find_by(expense_type_id: line.expense_type_id).reload.total
            end

            it 'does not change the proof_of_expense_number' do
              line      = created_lines.last
              old_value = line.proof_of_expense_number

              patch_update_line line_id: line.id

              assert_equal old_value, line.reload.proof_of_expense_number
            end

            it 'sets the right VAT amount' do
              vat = Goxygene::Vat.active.find_by(label: "Taux normal")
              patch_update_line attrs: { vat_id: vat.id }

              assert_equal (total / (1 + (vat.rate / 100))).round(2), last_line.amount
              assert_equal (total - last_line.amount)      .round(2), last_line.vat
            end

            it 'redirects to the SOO' do
              patch_update_line

              assert_redirected_to '/bureau_consultant/statement_of_operating_expenses/current'
            end

            it 'updates totals on SOO' do
              previous_total_with_taxes = current_soo.total_with_taxes
              previous_total            = current_soo.total

              line = created_lines.last

              previous_line_total_with_taxes = line.total_with_taxes
              previous_line_amount           = line.amount

              patch_update_line line_id: line.id

              new_total_with_taxes = previous_total_with_taxes - previous_line_total_with_taxes + total
              new_total            = previous_total            - previous_line_amount           + (total / (1 + (vat.rate / 100))).round(2)
              new_vat              = new_total_with_taxes - new_total

              assert_equal new_total_with_taxes, current_soo.reload.total_with_taxes
              assert_equal new_total,            current_soo.reload.total
              assert_equal new_vat,              current_soo.reload.vat
            end

            it 'reloads cumuls for the consultant' do
              patch_update_line

              assert_mock Accountancy
            end
          end

          describe 'when the label is missing' do
            it 'does not create any entry' do
              assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
                patch_update_line attrs: { label: '' }
              end
            end

            it 'displays an error message' do
              patch_update_line attrs: { label: '' }
              assert_response :success
            end
          end

          describe 'when the total is missing' do
            it 'does not create any entry' do
              assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
                patch_update_line attrs: { total_with_taxes: nil }
              end
            end

            it 'displays an error message' do
              patch_update_line attrs: { total_with_taxes: nil }
              assert_response :success
            end
          end

          describe 'when the total is invalid' do
            it 'does not create any entry' do
              assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
                patch_update_line attrs: { total_with_taxes: -42 }
              end
            end

            it 'displays an error message' do
              patch_update_line attrs: { total_with_taxes: -42 }
              assert_response :success
            end
          end

          describe 'when the date is missing' do
            it 'does not create any entry' do
              assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
                patch_update_line attrs: { date: nil }
              end
            end

            it 'displays an error message' do
              patch_update_line attrs: { date: nil }
              assert_response :success
            end
          end

          describe 'when the date is too far' do
            let(:invalid_date) { current_soo.date.end_of_month + 1.day }

            it 'does not create any entry' do
              assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
                patch_update_line attrs: { date: invalid_date }
              end
            end

            it 'displays an error message' do
              patch_update_line attrs: { date: invalid_date }
              assert_response :success
            end

            it 'does not update the existing entry' do
              line = created_lines.last
              previous_date = line.date

              patch_update_line attrs: { date: invalid_date }, line_id: line.id

              assert_equal previous_date, line.reload.date
            end
          end

          describe 'when the date is too old' do
            let(:invalid_date) { current_soo.date.beginning_of_month - 1.day }

            it 'does not create any entry' do
              assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
                patch_update_line attrs: { date: invalid_date }
              end
            end

            it 'displays an error message' do
              patch_update_line attrs: { date: invalid_date }
              assert_response :success
            end

            it 'does not update the existing entry' do
              line = created_lines.last
              previous_date = line.date

              patch_update_line attrs: { date: invalid_date }, line_id: line.id

              assert_equal previous_date, line.reload.date
            end
          end
        end

        describe 'when no SOO is curently in edition' do
          before do
            created_lines
            current_soo.submit!
          end

          it 'does not create the line' do
            assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
              patch_update_line
            end
          end

          it 'redirects to the new SOO page' do
            patch_update_line

            assert_redirected_to '/bureau_consultant/statement_of_operating_expenses/new'
          end
        end
      end

      describe 'on the create action' do
        describe 'when a SOO is in edition' do
          before do
            created_lines
            current_soo.reload

            Rails.cache.clear
            Accountancy = Minitest::Mock.new
            Accountancy.expect(:consultant_account_balances, balances, [consultant.id, environment: "FREELAND", clear_cache: true])
          end

          describe 'when the line is valid' do
            it 'creates a line' do
              assert_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
                post_create_line
              end
            end

            it 'sets the right values' do
              post_create_line

              assert_equal date,         last_line.date
              assert_equal label,        last_line.label
              assert_equal total,        last_line.total_with_taxes
              assert_equal vat_id,       last_line.vat_id
              assert_equal expense_type, last_line.expense_type
            end

            it 'does not create new OfficeOperatingExpenseTotal entries' do
              assert_no_difference 'Goxygene::OfficeOperatingExpenseTotal.count' do
                post_create_line
              end
            end

            it 'updates the OfficeOperatingExpenseTotal' do
              previous_total = current_soo.office_operating_expense_totals.find_by(expense_type_id: expense_type.id).total

              post_create_line

              assert_not_equal previous_total, current_soo.office_operating_expense_totals.find_by(expense_type_id: expense_type.id).reload.total
            end

            it 'sets the proof_of_expense_number' do
              post_create_line

              assert_not_nil last_line.proof_of_expense_number
            end

            it 'increments proof_of_expense_number' do
              post_create_line

              assert_equal created_lines.count + 1, last_line.proof_of_expense_number
            end

            it 'sets the right VAT amount' do
              vat = Goxygene::Vat.active.find_by(label: "Taux normal")
              post_create_line vat_id: vat.id

              assert_equal (total / (1 + (vat.rate / 100))).round(2), last_line.amount
              assert_equal (total - last_line.amount)      .round(2), last_line.vat
            end

            it 'redirects to the SOO' do
              post_create_line

              assert_redirected_to '/bureau_consultant/statement_of_operating_expenses/current'
            end

            it 'updates totals on SOO' do
              previous_total_with_taxes = current_soo.total_with_taxes
              previous_total            = current_soo.total

              post_create_line

              new_total_with_taxes = previous_total_with_taxes + total
              new_total            = previous_total            + (total / (1 + (vat.rate / 100))).round(2)
              new_vat              = new_total_with_taxes - new_total

              assert_equal new_total_with_taxes, current_soo.reload.total_with_taxes
              assert_equal new_total,            current_soo.reload.total
              assert_equal new_vat,              current_soo.reload.vat
            end

            it 'reloads cumuls for the consultant' do
              post_create_line

              assert_mock Accountancy
            end

            describe 'no vat on type' do
              let(:vat)          { Goxygene::Vat.active.find_by(label: "Taux normal")                     }
              let(:expense_type) { Goxygene::ExpenseType.for_expenses.where(has_vat: false).shuffle.first }

              it 'creates a line' do
                assert_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
                  post_create_line
                end
              end

              it 'sets the total_with_taxes' do
                post_create_line

                assert_equal total, last_line.total_with_taxes
              end

              it 'sets the total without taxes' do
                post_create_line

                assert_equal total, last_line.amount
              end

              it 'sets the vat' do
                post_create_line

                assert_equal 0, last_line.vat
              end

              it 'sets the vat_rate' do
                post_create_line

                assert_equal 1, last_line.vat_id
              end
            end
          end

          describe 'when the label is missing' do
            it 'does not create any entry' do
              assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
                post_create_line label: ''
              end
            end

            it 'displays an error message' do
              post_create_line label: ''
              assert_response :success
            end
          end

          describe 'when the total is missing' do
            it 'does not create any entry' do
              assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
                post_create_line total_with_taxes: nil
              end
            end

            it 'displays an error message' do
              post_create_line total_with_taxes: nil
              assert_response :success
            end
          end

          describe 'when the total is invalid' do
            it 'does not create any entry' do
              assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
                post_create_line total_with_taxes: -42
              end
            end

            it 'displays an error message' do
              post_create_line total_with_taxes: -42
              assert_response :success
            end
          end

          describe 'when the date is missing' do
            it 'does not create any entry' do
              assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
                post_create_line date: nil
              end
            end

            it 'displays an error message' do
              post_create_line date: nil
              assert_response :success
            end
          end

          describe 'when the date is after the DF month' do
            let(:invalid_date) { current_soo.date.end_of_month + 1.day }

            it 'does not create any entry' do
              assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
                post_create_line date: invalid_date
              end
            end

            it 'displays an error message' do
              post_create_line date: invalid_date
              assert_response :success
            end
          end

          describe 'when the date is before the DF month' do
            let(:invalid_date) { current_soo.date.beginning_of_month - 1.day }

            it 'does not create any entry' do
              assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
                post_create_line date: invalid_date
              end
            end

            it 'displays an error message' do
              post_create_line date: invalid_date
              assert_response :success
            end
          end

        end

        describe 'when no SOO is curently in edition' do
          before do
            created_lines
            current_soo.submit!
          end

          it 'does not create the line' do
            assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
              post_create_line
            end
          end

          it 'redirects to the new SOO page' do
            post_create_line

            assert_redirected_to '/bureau_consultant/statement_of_operating_expenses/new'
          end
        end
      end

    end

    describe 'when the consultant does not have expenses reimbursed' do
      before { consultant.update! granted_expenses: false }

      describe 'on the create action' do

        it 'does not create a new line' do
          assert_no_difference 'Goxygene::OfficeOperatingExpenseLine.count' do
            post_create_line
          end

        end

        it 'redirects to the home page' do
          post_create_line

          assert_redirected_to '/bureau_consultant/'
        end
      end
    end

  end

  describe 'not authenticated' do
    before do
      CasAuthentication.current_cas_authentication = cas_authentications(:jackie_denesik)
      created_lines
      CasAuthentication.current_cas_authentication = nil
    end

    describe 'on the create action' do
      it 'redirects to the authentication page' do
        post_create_line
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end

    describe 'on the update action' do
      it 'redirects to the authentication page' do
        patch_update_line
      end
    end

    describe 'on the destroy action' do
      it 'redirects to the authentication page' do
        delete_destroy_line
      end
    end

  end
end

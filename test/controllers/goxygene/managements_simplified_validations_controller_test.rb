require 'test_helper'

describe Goxygene::ManagementsSimplifiedValidationsController do

  describe 'authenticated as an administrator' do

    before do
      sign_in cas_authentications(:administrator)
    end

    describe 'when listing expenses' do
      before do
        Goxygene::ActivityReport.update_all(activity_report_expense_status: 'pending')
        Goxygene::OfficeOperatingExpense.update_all(operating_expenses_status: 'office_validated')

        get '/goxygene/managements/expenses/simplified_validations'
      end

      it 'renders the page' do
        assert_response :success
      end

      it 'displays pagination links' do
        assert_select 'nav.pagination'
      end

      it 'displays multiple items' do
        assert_select 'tbody tr.expense', 25
      end
    end

    describe 'when showing a DA' do
      let(:id) { Goxygene::ActivityReport.all.collect(&:id).shuffle.first }

      before do
        Goxygene::ActivityReport.update_all(activity_report_expense_status: 'pending')

        get "/goxygene/managements/expenses/simplified_validations/#{id}?type=DA"
      end

      it 'renders the page' do
        assert_response :success
      end
    end

    describe 'when showing a DDF' do
      let(:id) { Goxygene::OfficeOperatingExpense.all.collect(&:id).shuffle.first }

      before do
        Goxygene::OfficeOperatingExpense.update_all(operating_expenses_status: 'office_validated')

        get "/goxygene/managements/expenses/simplified_validations/#{id}?type=DDF"
      end

      it 'renders the page' do
        assert_response :success
      end
    end

    describe 'when validating a DDF' do
      let(:id)      { 60944 }
      let(:date)    { rand(20).days.ago.to_date }
      let(:expense) { Goxygene::OfficeOperatingExpense.find id }

      before do
        operating_expense = expense.operating_expense
        expense.update(operating_expense_id: nil, operating_expenses_status: 'office_validated')
        operating_expense&.destroy
      end

      it 'updates the expense_statement_received_on date' do
        patch "/goxygene/managements/expenses/simplified_validations/#{id}/validate?type=DDF", params: {
          expense_statement_received_on: date.strftime('%d/%m/%Y')
        }

        assert_equal date, expense.reload.expense_statement_received_on.to_date
      end

      it 'redirects to the validations list' do
        patch "/goxygene/managements/expenses/simplified_validations/#{id}/validate?type=DDF", params: {
          expense_statement_received_on: date.strftime('%d/%m/%Y')
        }

        assert_redirected_to '/goxygene/managements/expenses/simplified_validations'
      end

      it 'creates an expense report' do
        assert_difference 'Goxygene::ExpenseReport.count' do
          patch "/goxygene/managements/expenses/simplified_validations/#{id}/validate?type=DDF", params: {
            expense_statement_received_on: date.strftime('%d/%m/%Y')
          }
        end
      end

      describe 'when a previous DF was not validated' do
        before do
          expense.consultant.office_operating_expenses.where(year: expense.year, month: expense.month - 1).first.update operating_expenses_status: 'office_validated'

          patch "/goxygene/managements/expenses/simplified_validations/#{id}/validate?type=DDF", params: {
            expense_statement_received_on: date.strftime('%d/%m/%Y')
          }
        end

        it 'updates the expense_statement_received_on date' do
          assert_equal date, expense.reload.expense_statement_received_on.to_date
        end

        it 'redirects to the validations list' do
          assert_redirected_to '/goxygene/managements/expenses/simplified_validations'
        end

        it 'adds an entry to flash alert array' do
          assert request.flash.alert.include?("Il y a 1 ou plusieurs Dépenses de Fonctionnnement antérieure non-traitée(s)")
        end
      end

      describe 'when the consultant does not have a employment contract for the period' do
        before do
          expense.employment_contracts.destroy_all

          patch "/goxygene/managements/expenses/simplified_validations/#{id}/validate?type=DDF", params: {
            expense_statement_received_on: date.strftime('%d/%m/%Y')
          }
        end

        it 'updates the expense_statement_received_on date' do
          assert_equal date, expense.reload.expense_statement_received_on.to_date
        end

        it 'redirects to the validations list' do
          assert_redirected_to '/goxygene/managements/expenses/simplified_validations'
        end

        it 'adds an entry to flash alert array' do
          assert request.flash.alert.include?("Le consultant n'a pas de contrat de travail sur tout ou partie de la durée de la DDF")
        end
      end

      describe 'when the consultant does not have a wage for the DDF' do
        before do
          wages = [
            expense.consultant.wages.find_by(year: expense.year, month: expense.month),
            expense.consultant.wages.find_by(year: (expense.date - 1.month).year, month: (expense.date - 1.month).month),
            expense.consultant.wages.find_by(year: (expense.date - 2.month).year, month: (expense.date - 2.month).month),
            expense.consultant.wages.find_by(year: (expense.date - 3.month).year, month: (expense.date - 3.month).month),
          ]

          wages.compact.each do |wage|
            wage.activity_report.update wage_id: nil
            wage.destroy
          end

          patch "/goxygene/managements/expenses/simplified_validations/#{id}/validate?type=DDF", params: {
            expense_statement_received_on: date.strftime('%d/%m/%Y')
          }
        end

        it 'updates the expense_statement_received_on date' do
          assert_equal date, expense.reload.expense_statement_received_on.to_date
        end

        it 'redirects to the validations list' do
          assert_redirected_to '/goxygene/managements/expenses/simplified_validations'
        end

        it 'adds an entry to flash alert array' do
          assert request.flash.alert.include?("Il n'y a pas eu de salaire depuis plus de 3 mois pour ce consultant")
        end
      end

      describe 'when the amount is over 500' do
        let(:id) { Goxygene::OfficeOperatingExpense.where("total >= 500").all.collect(&:id).shuffle.first }

        before do
          patch "/goxygene/managements/expenses/simplified_validations/#{id}/validate?type=DDF", params: {
            expense_statement_received_on: date.strftime('%d/%m/%Y')
          }
        end

        it 'updates the expense_statement_received_on date' do
          assert_equal date, expense.reload.expense_statement_received_on.to_date
        end

        it 'redirects to the validations list' do
          assert_redirected_to '/goxygene/managements/expenses/simplified_validations'
        end

        it 'adds an entry to flash alert array' do
          assert request.flash.alert.include?("Montant de frais supérieurs à 500€")
        end
      end

    end

    describe 'when validating a DA' do
      let(:id)      { 89375 }
      let(:date)    { rand(20).days.ago.to_date }
      let(:expense) { Goxygene::ActivityReport.find id }

      before do
        expense.expense_report&.destroy
        expense.update activity_report_expense_status: 'office_validated'
      end

      it 'updates the expense_statement_received_on date' do
        patch "/goxygene/managements/expenses/simplified_validations/#{id}/validate?type=DA", params: {
          expense_statement_received_on: date.strftime('%d/%m/%Y')
        }

        assert_equal date, expense.reload.expense_statement_received_on.to_date
      end

      it 'redirects to the validations list' do
        patch "/goxygene/managements/expenses/simplified_validations/#{id}/validate?type=DA", params: {
          expense_statement_received_on: date.strftime('%d/%m/%Y')
        }

        assert_redirected_to '/goxygene/managements/expenses/simplified_validations'
      end

      it 'creates an expense report' do
        assert_difference 'Goxygene::ExpenseReport.count' do
          patch "/goxygene/managements/expenses/simplified_validations/#{id}/validate?type=DA", params: {
            expense_statement_received_on: date.strftime('%d/%m/%Y')
          }
        end
      end

      describe 'when a previous DA was not validated' do
        let(:id) { 149928 }

        before do
          expense.consultant.activity_reports.where(year: expense.year, month: expense.month - 1).first.update activity_report_status: 'office_validated'

          patch "/goxygene/managements/expenses/simplified_validations/#{id}/validate?type=DA", params: {
            expense_statement_received_on: date.strftime('%d/%m/%Y')
          }
        end

        it 'updates the expense_statement_received_on date' do
          assert_equal date, expense.reload.expense_statement_received_on.to_date
        end

        it 'redirects to the validations list' do
          assert_redirected_to '/goxygene/managements/expenses/simplified_validations'
        end

        it 'adds an entry to flash alert array' do
          assert request.flash.alert.include?("Il y a 1 ou plusieurs Déclaration(s) d'Activités antérieure non-traitée(s)")
        end
      end

      describe 'when some lines have not been validated' do
        let(:id) { 149928 }

        before do
          Goxygene::ActivityReport.update_all activity_report_status: 'office_editing'

          patch "/goxygene/managements/expenses/simplified_validations/#{id}/validate?type=DA", params: {
            expense_statement_received_on: date.strftime('%d/%m/%Y')
          }
        end

        it 'updates the expense_statement_received_on date' do
          assert_equal date, expense.reload.expense_statement_received_on.to_date
        end

        it 'redirects to the validations list' do
          assert_redirected_to '/goxygene/managements/expenses/simplified_validations'
        end

        it 'adds an entry to flash alert array' do
          assert request.flash.alert.include?("L'activité de la DA n'a pas été traitée")
        end
      end

      describe 'when the consultant does not have a employment contract for the period' do
        let(:id) { 149928 }

        before do
          expense.employment_contracts.destroy_all

          patch "/goxygene/managements/expenses/simplified_validations/#{id}/validate?type=DA", params: {
            expense_statement_received_on: date.strftime('%d/%m/%Y')
          }
        end

        it 'updates the expense_statement_received_on date' do
          assert_equal date, expense.reload.expense_statement_received_on.to_date
        end

        it 'redirects to the validations list' do
          assert_redirected_to '/goxygene/managements/expenses/simplified_validations'
        end

        it 'adds an entry to flash alert array' do
          assert request.flash.alert.include?("Le consultant n'a pas de contrat de travail sur tout ou partie de la durée de la DA")
        end
      end

      describe 'when the consultant does not have a wage for the DA' do
        let(:id) { 149928 }

        before do
          wage = expense.consultant.wages.find_by(year: expense.year, month: expense.month)
          wage.activity_report.update wage_id: nil
          wage.destroy

          patch "/goxygene/managements/expenses/simplified_validations/#{id}/validate?type=DA", params: {
            expense_statement_received_on: date.strftime('%d/%m/%Y')
          }
        end

        it 'updates the expense_statement_received_on date' do
          assert_equal date, expense.reload.expense_statement_received_on.to_date
        end

        it 'redirects to the validations list' do
          assert_redirected_to '/goxygene/managements/expenses/simplified_validations'
        end

        it 'adds an entry to flash alert array' do
          assert request.flash.alert.include?("Le consultant n'a pas de salaire sur la période de la DA")
        end
      end

      describe 'when the amount is over 500' do
        let(:id) { 149928 }

        before do
          patch "/goxygene/managements/expenses/simplified_validations/#{id}/validate?type=DA", params: {
            expense_statement_received_on: date.strftime('%d/%m/%Y')
          }
        end

        it 'updates the expense_statement_received_on date' do
          assert_equal date, expense.reload.expense_statement_received_on.to_date
        end

        it 'redirects to the validations list' do
          assert_redirected_to '/goxygene/managements/expenses/simplified_validations'
        end

        it 'adds an entry to flash alert array' do
          assert request.flash.alert.include?("Montant de frais supérieurs à 500€")
        end
      end

    end

  end

  describe 'not authenticated' do
    describe 'when listing expenses' do
      it 'redirects to the authentication page' do
        get '/goxygene/managements/expenses/simplified_validations'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end
  end
end

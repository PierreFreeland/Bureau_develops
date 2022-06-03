require 'bureau_consultant/statement_of_operating_expenses_presenter'

module BureauConsultant
  class StatementOfOperatingExpensesRequestsController < BureauConsultant::ApplicationController
    before_action :require_consultant!
    before_action :load_statement_of_operating_expenses_requests, only: %i{ history export }

    def history
    end

    def export
      render xlsx: 'export' , filename: 'export_statement_of_operating_expenses_requests'
    end

    def history_show
      @statement_of_operating_expenses_request = current_consultant.office_operating_expenses.find(params[:id])
      @company = @statement_of_operating_expenses_request.itg_company
      @consultant = ConsultantPresenter.new(@statement_of_operating_expenses_request.consultant, view_context)
      @statement_of_operating_expenses_request_lines = @statement_of_operating_expenses_request.office_operating_expense_lines.order(:id)

      @number_format = { separator: ',', delimiter: '', precision: 2 }

      respond_to do |format|
        format.pdf do
          render pdf: "@statement_of_operating_expenses_request_#{@statement_of_operating_expenses_request.id}",
                 margin: { bottom: 15, top: 8 },
                 footer: { html: { template: 'bureau_consultant/statement_of_operating_expenses_requests/footer.pdf' } },
                 orientation: 'Landscape',
                 show_as_html: false
        end
      end
    end

    private

    def load_statement_of_operating_expenses_requests
      prepare_date_search_params(:date_without_day_gteq, :date_without_day_lteq)
      params[:q] ||= {}
      params[:q][:s] ||= 'month_and_year desc'

      @q = current_consultant.office_operating_expenses.ransack(params[:q])
      @statement_of_operating_expenses_requests = StatementOfOperatingExpensesPresenter.collection(result_for(@q), view_context)
    end
  end
end

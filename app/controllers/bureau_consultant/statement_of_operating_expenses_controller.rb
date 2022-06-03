require 'bureau_consultant/statement_of_operating_expenses_presenter'

module BureauConsultant
  class StatementOfOperatingExpensesController < BureauConsultant::ApplicationController
    before_action :require_consultant!
    before_action :require_refund_expenses

    before_action :redirect_to_current_if_exists, only: %i{
      new
      index
      create
    }

    before_action :require_statement_of_operating_expenses_request, except: %i{
      new
      create
      history
      history_show
      export
    }

    before_action :load_statement_of_operating_expenses, only: %i{
      export
      history
    }

    def index     ; end
    def show      ; end
    def synthesis ; end

    def new
      render :not_available if current_consultant.allowed_statement_of_operating_expenses_request_dates.empty?
    end

    def create
      current_consultant.office_operating_expenses.create!(
        year:  Date.parse(statement_of_operating_expenses_request_params[:date]).year,
        month: Date.parse(statement_of_operating_expenses_request_params[:date]).month
      )

      redirect_to_current

    rescue ActiveRecord::RecordNotUnique # handle the case where a user double click on the creation button
      redirect_to statement_of_operating_expenses_path
    end

    def destroy
      statement_of_operating_expenses_request.destroy

      redirect_to history_statement_of_operating_expenses_requests_path
    end

    def submit
      statement_of_operating_expenses_request.assign_attributes statement_of_operating_expenses_request_submit_params
      statement_of_operating_expenses_request.submit!
      head :ok
    rescue ActiveRecord::RecordInvalid
      head :not_ok
    end

    def history
    end

    def export
      render xlsx: 'export' , filename: 'export_statement_of_operating_expenses'
    end

    def history_show
      @statement_of_operating_expense = current_consultant.operating_expenses.find(params[:id])
      @statement_of_operating_expenses_request = @statement_of_operating_expense.office_operating_expense
      @company = @statement_of_operating_expense.itg_company
      @consultant = ConsultantPresenter.new(@statement_of_operating_expense.consultant, view_context)
      @statement_of_operating_expenses_lines = @statement_of_operating_expense.operating_expense_lines

      @number_format = { separator: ',', delimiter: '', precision: 2 }

      respond_to do |format|
        format.pdf do
          render pdf: "statement_of_operating_expense_#{@statement_of_operating_expense.id}",
                 margin: { bottom: 15, top: 8 },
                 footer: { html: { template: 'bureau_consultant/statement_of_operating_expenses/footer.pdf' } },
                 orientation: 'Landscape',
                 show_as_html: false
        end
      end
    end

    private

    def redirect_to_current
      redirect_to statement_of_operating_expense_path(:current)
    end

    helper_method :current_line
    def current_line
      @current_line ||= if params[:line_id]
                          lines.find(params[:line_id])
                        else
                          lines.new(vat_id: 12)
                        end
    end

    helper_method :statement_of_operating_expenses_request
    def statement_of_operating_expenses_request
      return @statement_of_operating_expenses_request if @statement_of_operating_expenses_request

      @statement_of_operating_expenses_request = current_consultant.office_operating_expenses.in_edition.first
      if @statement_of_operating_expenses_request
        @statement_of_operating_expenses_request = StatementOfOperatingExpensesPresenter.new(@statement_of_operating_expenses_request, view_context)
      end

      @statement_of_operating_expenses_request
    end

    helper_method :lines
    def lines
      @lines ||= StatementOfOperatingExpensesLinePresenter.collection(
        statement_of_operating_expenses_request.office_operating_expense_lines,
        view_context
      )
    end

    helper_method :lines_by_date
    def lines_by_date
      return @lines_by_date if @lines_by_date

      @lines_by_date = {}

      lines.each do |line|
        @lines_by_date[line.date] ||= []
        @lines_by_date[line.date] << StatementOfOperatingExpensesLinePresenter.new(line, view_context)
      end

      # TODO : fix the data model by adding an item_number
      # @lines_by_date.keys.each { |k| @lines_by_date[k].sort_by! &:item_number }

      @lines_by_date
    end

    def redirect_to_current_if_exists
      redirect_to_current if statement_of_operating_expenses_request
    end

    def require_statement_of_operating_expenses_request
      redirect_to new_statement_of_operating_expense_path if statement_of_operating_expenses_request.nil?
    end

    def require_refund_expenses
      redirect_to bureau_consultant.root_path unless current_consultant.reload.allowed_expenses_refund?
    end

    def statement_of_operating_expenses_request_params
      params
        .require(:statement_of_operating_expenses_request)
        .permit(%i{
          date
        })
    end

    def statement_of_operating_expenses_request_submit_params
      params
        .require(:statement_of_operating_expenses_request)
        .permit(%i{
          consultant_comment
        })
    end

    def load_statement_of_operating_expenses
      prepare_date_search_params(:date_without_day_gteq, :date_without_day_lteq)
      params[:q] ||= {}
      params[:q][:s] ||= 'month_and_year desc'

      @q = current_consultant.operating_expenses.ransack(params[:q])
      @statement_of_operating_expenses = StatementOfOperatingExpensesPresenter.collection(result_for(@q), view_context)
    end
  end
end

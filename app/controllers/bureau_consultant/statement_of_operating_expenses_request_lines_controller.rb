module BureauConsultant
  class StatementOfOperatingExpensesRequestLinesController < BureauConsultant::ApplicationController
    before_action :require_consultant!
    before_action :require_refund_expenses,
                  :require_statement_of_operating_expenses_request

    def create
      @current_line = lines.new statement_of_operating_expenses_request_line_params

      if @current_line.save
        redirect_to statement_of_operating_expense_path(:current)
      else
        render 'bureau_consultant/statement_of_operating_expenses/show'
      end
    end

    def update
      if current_line.update statement_of_operating_expenses_request_line_params
        redirect_to statement_of_operating_expense_path(:current)
      else
        render 'bureau_consultant/statement_of_operating_expenses/show'
      end
    end

    def destroy
      current_line.destroy

      redirect_to statement_of_operating_expense_path(:current)
    end

    private

    def statement_of_operating_expenses_request_line_params
      params
        .require(:office_operating_expense_line)
        .permit(%i{
          date
          expense_type_id
          label
          total_with_taxes
          vat_id
        })
    end

    def require_refund_expenses
      redirect_to bureau_consultant.root_path unless current_consultant.reload.allowed_expenses_refund?
    end

    def require_statement_of_operating_expenses_request
      redirect_to new_statement_of_operating_expense_path if statement_of_operating_expenses_request.nil?
    end

    # OPTIMIZE : massive duplication from parent controller, should be fixed
    helper_method :current_line
    def current_line
      @current_line ||= if params[:id]
                          lines.find(params[:id])
                        else
                          lines.new
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
      @lines ||= statement_of_operating_expenses_request.office_operating_expense_lines
    end

    helper_method :lines_by_date
    def lines_by_date
      return @lines_by_date if @lines_by_date

      @lines_by_date = {}

      lines.each do |line|
        next if line.new_record?
        @lines_by_date[line.date] ||= []
        @lines_by_date[line.date] << StatementOfOperatingExpensesLinePresenter.new(line, view_context)
      end

      @lines_by_date
    end

  end
end

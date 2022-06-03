require 'bureau_consultant/statement_of_activities_presenter'

module BureauConsultant
  class StatementOfActivitiesRequestsController < BureauConsultant::ApplicationController
    before_action :require_consultant!
    before_action :load_statement_of_activities_requests, only: %i{ history export }

    def mission_expense

    end

    def manage_mission

    end

    def manage_add_mission

    end

    def mission_month_select

    end

    def synthesis
    end

    def history
    end

    def history_show
      @statement_of_activities_request = current_consultant.office_activity_reports.find(params[:id])
      @society = @statement_of_activities_request.itg_company
      @consultant = Goxygene::ConsultantPresenter.new(@statement_of_activities_request.consultant, view_context)
      @statement_of_activities_request_lines = @statement_of_activities_request.office_activity_report_lines.order(:date)

      @number_format = { separator: '.', delimiter: ' ', format: '%n' }

      respond_to do |format|
        format.pdf do
          render pdf: "statement_of_activities_request_#{@statement_of_activities_request.id}",
                 margin: { bottom: 15, top: 8 },
                 footer: { html: { template: 'bureau_consultant/statement_of_activities_requests/footer.pdf' } },
                 orientation: 'Landscape',
                 show_as_html: false
        end
      end
    end

    def export
      render xlsx: 'export' , filename: 'export_statement_of_activities_requests'
    end

    private

    def load_statement_of_activities_requests
      prepare_date_search_params(:date_without_day_gteq, :date_without_day_lteq)
      params[:q] ||= {}
      params[:q][:s] ||= 'month_and_year desc'

      @q = current_consultant.office_activity_reports.ransack(params[:q])
      @statement_of_activities_requests = StatementOfActivitiesPresenter.collection(result_for(@q), view_context)
    end
  end
end

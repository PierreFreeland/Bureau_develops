require 'bureau_consultant/statement_of_activities_presenter'

module BureauConsultant
  class StatementOfActivitiesController < BureauConsultant::ApplicationController
    before_action :require_consultant!

    before_action :require_statement_of_activities_request, except: %i{
      first_time_da
      synthesis_2_step
      create
      create_previous_empty
      index
      submit
      validate
      wait_for_validate
      history
      history_show
      export
    }

    before_action :require_refund_expenses, :require_expenses_in_edition_state, only: %i{
      mission_expense
      manage_mission
      manage_mission_expense
      update_expense
      destroy_expense
      mission_month_select
    }

    before_action :require_allowed_expenses, only: %i{
      manage_mission_expense
      update_expense
      destroy_expense
    }

    before_action :redirect_to_expenses_if_activities_validated, only: %i{
      handle_expenses
      first_time_new
      new
      manage_activity_day
      update_activity_day
      duplicate_activity_on_month
      duplicate_new
      duplicate_few_days
    }

    before_action :must_respect_dsn_office_date, only: %i{
      first_time_new
      new
      update_mission_location
      handle_expenses
      synthesis_2_calendar
      synthesis_3_step
      validate
      manage_activity_day
      update_activity_day
      duplicate_activity_on_month
      duplicate_new
      duplicate_new
    }

    before_action :load_statement_of_activities, only: %i{
      history
      export
    }

    after_action :clear_errors_in_session, except: %i{
      duplicate_few_days
      duplicate_activity_on_month
      update_activity_day
    }

    after_action :set_errors_for_duplicated_lines, only: %i{
      duplicate_few_days
      duplicate_activity_on_month
    }

    def index
      redirect_to first_time_da_statement_of_activities_path
    end

    def first_time_new
    end

    def first_time_da
      if statement_of_activities_request.nil?
        redirect_to wait_for_validate_statement_of_activities_path if current_consultant.statement_of_activities_request_months.empty?
      else
        redirect_to new_statement_of_activity_path
      end
    end

    def create
      soa = current_consultant.office_activity_reports.create!(
        year:  Date.parse(statement_of_activities_request_params[:date]).year,
        month: Date.parse(statement_of_activities_request_params[:date]).month,
        no_activity: statement_of_activities_request_params[:no_activity]
      )

      if statement_of_activities_request_params[:no_activity] == 'true'
        soa.submit!
        redirect_to history_statement_of_activities_requests_path
      else
        redirect_to first_time_new_statement_of_activities_path
      end

      session[:expenses_notice_displayed] = nil

    rescue ActiveRecord::RecordNotUnique # handle the case where a user double click on the creation button
      redirect_to statement_of_activities_path
    end

    def create_previous_empty
      # remove last month, which may be filled later by consultant
      last_month = current_consultant.office_activity_reports.where(year: Date.current.year).order(:month).last&.month
      months_to_create_empty = ((last_month || 1)..(Date.current.month - 1)).to_a

      # months_to_create_empty = current_consultant.statement_of_activities_request_months[0..-2]

      # binding.pry

      months_to_create_empty.each do |month|
        da = current_consultant.office_activity_reports.create!(
          year:  Date.current.year,
          month: month,
          no_activity: true,
          activity_report_status: :completed,
          activity_report_expense_status: :completed,
        )
        da.accept_as_empty
      end

      head :ok
    end

    def new
      if statement_of_activities_request.empty?
        redirect_to first_time_new_statement_of_activities_path
      end
    end

    def destroy
      statement_of_activities_request.destroy!
      redirect_to first_time_da_statement_of_activities_path
    end

    def destroy_activity
      activity.destroy!
      redirect_to new_statement_of_activity_path
    end

    # OPTIMIZE : the code from the duplicate process is massively duplicated and can be refactored
    def duplicate_activity_on_month
      @current_date = Date.parse(params[:date])
      @lines = activities.where(date: @current_date)

      @line = if params[:line_id]
                @lines.find(params[:line_id])
              else
                statement_of_activities_request.office_activity_report_lines.new(date: @current_date)
              end

      # check if activity is valid for selected day
      @line.assign_attributes statement_of_activities_request_line_params

      if @line.valid?

        @duplicated_lines = []

        # iterate over selectable_days and create activity if condition is respected
        selectable_days.each do |day|
          current_date = Date.parse(day)
          next if current_date.saturday? || current_date.sunday?
          current_line = statement_of_activities_request.office_activity_report_lines.reload.new(date: current_date)
          current_line.update statement_of_activities_request_line_params
          @duplicated_lines << current_line
        end

        statement_of_activities_request.reload.update_counts

        # redirect
        redirect_to new_statement_of_activity_path
      else
        render :manage_activity_day
      end
    rescue ActiveRecord::RecordInvalid => e
      session[:errors] = e.record.errors.full_messages
      redirect_to new_statement_of_activity_path
    end

    def duplicate_new
      @current_date = Date.parse(params[:date])
      @lines = activities.where(date: @current_date)

      @line = if params[:line_id]
                @lines.find(params[:line_id])
              else
                statement_of_activities_request.office_activity_report_lines.new(date: @current_date)
              end

      # check if activity is valid for selected day
      @line.assign_attributes statement_of_activities_request_line_params
      if @line.valid?
        #
      else
        render :manage_activity_day
      end
    end

    def duplicate_few_days
      @current_date = Date.parse(statement_of_activities_duplicated_line_params[:date])
      @lines = activities.where(date: @current_date)

      @line = if !statement_of_activities_duplicated_line_params[:line_id].blank?
                @lines.find(statement_of_activities_duplicated_line_params[:line_id])
              else
                statement_of_activities_request.office_activity_report_lines.new(date: @current_date)
              end

      @line.assign_attributes statement_of_activities_request_line_params
      if @line.valid?

        @duplicated_lines = []

        JSON.parse(statement_of_activities_duplicated_line_params[:selected_dates])["data"].each do |day|
          current_line = statement_of_activities_request.office_activity_report_lines.new(date: day)
          current_line.update statement_of_activities_request_line_params
          @duplicated_lines << current_line
        end
      end

      statement_of_activities_request.reload.update_counts

      redirect_to new_statement_of_activity_path
    rescue ActiveRecord::RecordInvalid => e
      session[:errors] = e.record.errors.full_messages
      redirect_to new_statement_of_activity_path
    end

    def manage_activity_day
      @current_date = Date.parse(params[:date])
      @lines = statement_of_activities_request.
        office_activity_report_lines.
        where(date: @current_date)

      @can_add_new_activity = (@lines.sum(:time_span) < 1)

      @line = if params[:line_id]
                @lines.find(params[:line_id])
              elsif !@can_add_new_activity
                @lines.first
              else
                statement_of_activities_request.office_activity_report_lines.new(date: @current_date)
              end
    end

    def update_activity_day
      # OPTIMIZE : fix duplicated code
      @current_date = Date.parse(params[:date])
      @lines = statement_of_activities_request.
        office_activity_report_lines.
        where(date: @current_date)

      @can_add_new_activity = (@lines.sum(:time_span) < 1)

      @line = if params[:line_id]
                @lines.find(params[:line_id])
              else
                statement_of_activities_request.office_activity_report_lines.new(date: @current_date)
              end

      if @line.update statement_of_activities_request_line_params
        session[:warnings] = @line.warnings.full_messages if @line.warnings?
        redirect_to new_statement_of_activity_path
      else
        render :manage_activity_day
      end
    end

    def update_activity_day_on_manage_mission
      @line = statement_of_activities_request.office_activity_report_lines.
                  new(statement_of_activities_request_line_manage_mission_params)

      if @line.save
        session[:warnings] = @line.warnings.full_messages if @line.warnings?
        redirect_to manage_mission_statement_of_activities_path
      else
        render :manage_mission
      end
    end

    def update_mission_location
      statement_of_activities_request.updating_mission_location = true

      if statement_of_activities_request.update(
           statement_of_activities_request_mission_location_params
         )

        if current_consultant.reload.granted_expenses
          redirect_to mission_expense_statement_of_activities_path
        else
          redirect_to synthesis_2_calendar_statement_of_activities_path
        end

      else
        render :new
      end
    end

    def handle_expenses
      redirect_to mission_month_select_statement_of_activities_path
    end

    def mission_expense
    end

    def manage_mission
      @line = statement_of_activities_request.office_activity_report_lines.new
    end

    def manage_mission_expense
      @mission_expense = if params[:expense_id]
                           activity.office_activity_report_expenses.find params[:expense_id]
                         else
                           activity.office_activity_report_expenses.new
                         end
    end

    def update_expense
      # OPTIMIZE : dry me
      @mission_expense = if params[:expense_id]
                           activity.office_activity_report_expenses.find params[:expense_id]
                         else
                           activity.office_activity_report_expenses.new
                         end

      if @mission_expense.update expense_params
        redirect_to manage_mission_statement_of_activities_path(activity_id: activity.id)
      else
        render :manage_mission_expense
      end
    end

    def update_batch_expense
      @expense_data = []
      params[:data].each do |k, v|
        if v[:form_id].in? %w[new_statement_of_activities_request_line new_office_activity_report_line]
          line = statement_of_activities_request.office_activity_report_lines.
            missions.new(statement_of_activities_request_line_manage_mission_params(v[:value]))

          line.save
          @expense_data << { expense: line,
                             form_id: v[:form_id] }
          session[:warnings] = line.warnings.full_messages if line.warnings?
        else
          activity = activities.find(expense_params(v[:value])[:activity_id])
          mission_expense = activity.expenses.new
          mission_expense.update expense_params(v[:value])
          @expense_data << { expense: mission_expense,
                             form_id: v[:form_id],
                             activity: activity }
        end
      end if params[:data]
    end

    def destroy_expense
      @mission_expense = activity.office_activity_report_expenses.find params[:expense_id]
      @mission_expense.destroy!
      redirect_to manage_mission_statement_of_activities_path
    end

    def mission_month_select
    end

    def synthesis
    end

    def history
    end

    def history_show
      @statement_of_activity = current_consultant.activity_reports.find(params[:id])
      @statement_of_activities_request = @statement_of_activity.office_activity_report
      @society = @statement_of_activity.itg_company
      @consultant = Goxygene::ConsultantPresenter.new(@statement_of_activity.consultant, view_context)
      @statement_of_activities_lines = @statement_of_activity.activity_report_lines.order(:date)

      @number_format = { separator: '.', delimiter: ' ', format: '%n' }

      respond_to do |format|
        format.pdf do
          render pdf: "statement_of_activity_#{@statement_of_activity.id}",
                 margin: { bottom: 15, top: 8 },
                 footer: { html: { template: 'bureau_consultant/statement_of_activities/footer.pdf' } },
                 orientation: 'Landscape',
                 show_as_html: false
        end
      end
    end

    def synthesis_2_step
      if statement_of_activities_request.nil?
        @statement_of_activities_request = current_consultant.office_activity_reports.new(
          year:  Date.parse(statement_of_activities_request_params[:date]).year,
          month: Date.parse(statement_of_activities_request_params[:date]).month
        )
      end
    end

    def synthesis_3_step
    end

    def submit
      if params[:statement_of_activities_request] && params[:statement_of_activities_request][:no_activity]
        current_consultant.office_activity_reports.transaction do
          @statement_of_activities_request = current_consultant.office_activity_reports.create!(
            year:  Date.parse(statement_of_activities_request_params[:date]).year,
            month: Date.parse(statement_of_activities_request_params[:date]).month,
            no_activity: true,
            gross_wage: params[:statement_of_activities_request][:gross_wage]
          )
          @statement_of_activities_request.submit!
        end
      else
        if statement_of_activities_request.nil? || \
           ( params[:activities_only] && statement_of_activities_request.activity_report_status != 'office_editing' ) || \
           ( params[:activities_only].blank? && statement_of_activities_request.activity_report_expense_status != 'office_editing' )
          # prevent a DDA from being submited multiple times
          redirect_to first_time_da_statement_of_activities_path
          return
        else
          current_consultant.office_activity_reports.transaction do
            statement_of_activities_request.assign_attributes statement_of_activities_request_validation_params
            statement_of_activities_request.in_validation_phase = true
            statement_of_activities_request.submit! params[:activities_only] && current_consultant.granted_expenses ? :activities : :all
          end
        end
      end

      head :ok

    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.warn "errors: #{e.record.errors.full_messages}"
      render status: 422, json: { errors: e.record.errors.full_messages }
    end

    def validate
      if params[:statement_of_activities_request] && params[:statement_of_activities_request][:no_activity]
        @statement_of_activities_request = current_consultant.office_activity_reports.new(
          year:  Date.parse(statement_of_activities_request_params[:date]).year,
          month: Date.parse(statement_of_activities_request_params[:date]).month
        )
      else
        if params[:activities_only]
          statement_of_activities_request.activity_report_status = :office_validated
        else
          statement_of_activities_request.activity_report_status = :office_validated
          statement_of_activities_request.activity_report_expense_status = :office_validated
        end
      end

      statement_of_activities_request.in_validation_phase = true
      statement_of_activities_request.assign_attributes statement_of_activities_request_validation_params

       if statement_of_activities_request.valid?
        head :ok
      else
        render status: 422, json: { errors: statement_of_activities_request.errors.full_messages }
      end
    end

    def export
      render xlsx: 'export' , filename: 'export_statement_of_activities'
    end

    private

    def redirect_to_expenses_if_activities_validated
      redirect_to manage_mission_statement_of_activities_path unless statement_of_activities_request.activities_in_edition?
    end

    def require_statement_of_activities_request
      redirect_to first_time_da_statement_of_activities_path if statement_of_activities_request.nil?
    end

    def require_refund_expenses
      current_consultant.reload
      redirect_to synthesis_3_step_statement_of_activities_path if !current_consultant.allowed_expenses_refund?
    end

    def require_expenses_in_edition_state
      redirect_to synthesis_3_step_statement_of_activities_path unless statement_of_activities_request.expenses_in_edition?
    end

    def require_allowed_expenses
      redirect_to manage_mission_statement_of_activities_path unless activity.has_expenses_allowed
    end

    def must_respect_dsn_office_date
      if statement_of_activities_request && statement_of_activities_request.activities_in_edition? && !statement_of_activities_request.in_dsn_date?
        statement_of_activities_request.reject
        flash[:alert] ||= []
        flash[:alert] << "Votre déclaration d'activité vient d'être rejetée car sa date limite est maintenant dépassée"
        redirect_to statement_of_activities_path
      end
    end

    helper_method :expenses_notice_displayed?
    def expenses_notice_displayed?
      if session[:expenses_notice_displayed].nil?
        session[:expenses_notice_displayed] = true
        false
      else
        session[:expenses_notice_displayed]
      end
    end

    helper_method :activity
    def activity
      @activity ||= activities.find(params[:activity_id])
    end

    helper_method :current_month
    def current_month
      @current_month ||= statement_of_activities_request.date
    end

    helper_method :statement_of_activities_request
    def statement_of_activities_request
      return @statement_of_activities_request if @statement_of_activities_request

      @statement_of_activities_request = current_consultant.current_statement_of_activities_request

      if @statement_of_activities_request
        @statement_of_activities_request = StatementOfActivitiesPresenter.new(
          @statement_of_activities_request,
          view_context
        )
      end

      @statement_of_activities_request
    end

    helper_method :activities
    def activities
      @activities ||= statement_of_activities_request.
        office_activity_report_lines.
        includes(:activity_type).
        order(:date)
    end

    helper_method :expenses
    def expenses
      @expenses ||= statement_of_activities_request.
        office_activity_report_lines.
        expenses.
        includes(:expense_type)
    end

    helper_method :days_with_activity
    def days_with_activity
      return @days_with_activity if @days_with_activity

      @days_with_activity = {}

      activities.each do |activity|
        @days_with_activity[activity.date.to_date.iso8601] ||= { mission: 0, development: 0, unemployment: 0, label: [] }

        if activity.is_mission?
          @days_with_activity[activity.date.to_date.iso8601][:mission] += activity.time_span.to_f
          @days_with_activity[activity.date.to_date.iso8601][:label].push "Mission #{activity.label}"
        elsif activity.is_unemployment?
          @days_with_activity[activity.date.to_date.iso8601][:unemployment] += activity.time_span.to_f
          @days_with_activity[activity.date.to_date.iso8601][:label].push "Chômage partiel #{activity.label}"
        else
          @days_with_activity[activity.date.to_date.iso8601][:development] += activity.time_span.to_f
          @days_with_activity[activity.date.to_date.iso8601][:label].push "Développement #{activity.label}"
        end
      end

      @days_with_activity
    end

    helper_method :selectable_days
    def selectable_days
      return @selectable_days if @selectable_days

      @selectable_days = (current_month.beginning_of_month..current_month.end_of_month).to_a.collect(&:iso8601)
    end

    def set_errors_for_duplicated_lines
      if @duplicated_lines && !@duplicated_lines.empty?

        invalid_dates = @duplicated_lines.collect { |line| line.errors.any? ? line.date.to_date.strftime('%d-%m-%Y') : nil } .compact

        if invalid_dates.any?
          session[:errors] ||= []
          session[:errors] << I18n.t('statement_of_activities.duplicate_error_message', dates: invalid_dates.join(', '))
        end

        if first_line_with_warning = @duplicated_lines.detect { |line| line.warnings? }
          session[:warnings] = first_line_with_warning.warnings.full_messages
        end
      end
    end

    def clear_errors_in_session
      session[:errors]   = nil
      session[:warnings] = nil
    end

    def statement_of_activities_request_params
      params
        .require(:statement_of_activities_request)
        .permit(%i{
          date
          no_activity
        })
    end

    def statement_of_activities_request_mission_location_params
      params
        .require(:office_activity_report)
        .permit(%i{
          mission_zip_code
          mission_in_foreign_country
        })
    end


    def statement_of_activities_request_line_params
      params
        .require(:office_activity_report_line)
        .permit(%i{
          activity_type_id
          label
          time_span
        })
    end

    def statement_of_activities_request_line_manage_mission_params(options = nil)
      options ||= params
      options
          .require(:office_activity_report_line)
          .permit(%i{
          activity_type_id
          label
          time_span
          date
        })
    end

    def statement_of_activities_duplicated_line_params
      params
        .require(:duplicated_line)
        .permit(%i{
          date
          line_id
          selected_dates
        })
    end

    def expense_params(options = nil)
      options ||= params
      options
        .require(:office_activity_report_expense)
        .permit(%i{
          expense_type_id
          label
          total
          vat
          kilometers
          activity_id
        })
    end

    def statement_of_activities_request_validation_params
      params
        .require(:office_activity_report)
        .permit(%i{
          consultant_comment
          gross_wage
          no_activity
          attachment
        })
    end

    def load_statement_of_activities
      prepare_date_search_params(:date_without_day_gteq, :date_without_day_lteq)
      params[:q] ||= {}
      params[:q][:s] ||= 'month_and_year desc'

      @q = current_consultant.activity_reports.ransack(params[:q])
      @statement_of_activities = StatementOfActivitiesPresenter.collection(result_for(@q), view_context)
    end
  end
end

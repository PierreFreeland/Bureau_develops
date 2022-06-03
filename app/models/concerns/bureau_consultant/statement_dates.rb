module BureauConsultant
  module StatementDates
    extend ActiveSupport::Concern

    def allowed_statement_of_operating_expenses_request_dates
      return @allowed_statement_of_operating_expenses_request_dates if @allowed_statement_of_operating_expenses_request_dates

      @allowed_statement_of_operating_expenses_request_dates = []

      last = office_operating_expenses.order('year ASC, month ASC').last
      last_date = last ? last.date : 12.months.ago.beginning_of_month.to_date

      0.upto(11).each do |n|
        date = n.months.ago.beginning_of_month.to_date
        break if date == last_date
        @allowed_statement_of_operating_expenses_request_dates << date
      end

      @allowed_statement_of_operating_expenses_request_dates
    end

    def first_possible_statement_of_activities_request_month
      return @first_possible_statement_of_activities_request_month if @first_possible_statement_of_activities_request_month

      return nil if statement_of_activities_request_months.empty?

      if office_activity_reports.for_date(statement_of_activities_request_months.last).empty?
        @first_possible_statement_of_activities_request_month = statement_of_activities_request_months.last.beginning_of_month
      end

      @first_possible_statement_of_activities_request_month
    end

    # returns an array of possible dates for DA, if any
    # TODO : refactor this (raw implementation of DDA_MONTH diagram)
    def statement_of_activities_request_months
      return @statement_of_activities_request_months if @statement_of_activities_request_months

      @statement_of_activities_request_months = []

      return [] if employment_contracts.empty?

      last_da = office_activity_reports.order(:year, :month).last

      employment_contracts.each do |contract|

        current_year           = Date.current.year
        current_month          = Date.current.end_of_month
        beginning_of_year      = Date.current.beginning_of_year
        first_date = nil
        last_date  = nil

        if office_activity_reports.empty?

          if wages.empty?
            first_date = contract.starting_date.year == current_year ? contract.starting_date.to_date : beginning_of_year
          else
            last_salary = wages.last
            last_salary_date = Date.new(last_salary.year, last_salary.month)
            first_date = if current_year == last_salary_date.year
                           last_salary_date + 1.month
                         else
                           beginning_of_year
                         end
          end
        else
          last_da          = office_activity_reports.order("year ASC, month ASC").last
          last_salary      = wages.last || last_da
          last_salary_date = Date.new(last_salary.year, last_salary.month)
          if last_da.date.year == current_year
            first_date = if (last_salary_date > last_da.date)
                           last_salary_date + 1.month
                         else
                           last_da.date + 1.month
                         end
          else
            first_date = if ((last_salary_date + 1.month) > beginning_of_year)
                           last_salary_date + 1.month
                         else
                            beginning_of_year
                         end
          end
        end

        last_date = if contract.ended_on.nil? || contract.ended_on.year > current_year
                      current_month.beginning_of_month
                    elsif contract.ended_on.year < current_year
                      current_month.beginning_of_month
                    else
                      [contract.ended_on.to_date, current_month].min.beginning_of_month
                    end

        @statement_of_activities_request_months += (first_date.month..last_date.month).collect do |m|
          m_date = Date.new(first_date.year, m)
          # last step : refine list of months to match opened employment contracts and if no previous
          if m_date.year == current_year && \
             employment_contracts.for_month(m_date).any? && \
             (last_da.nil? || (last_da && m_date > last_da.date))
            m_date
          end
        end.compact

      end

      # as asked by PLW, the current and previous month are always creatable
      previous_month       = 1.month.ago.to_date.beginning_of_month
      previous_month_name  = I18n.l(previous_month, format: '%B', locale: :fr).to_ascii.upcase
      previous_month_limit = Date.current.end_of_month
      # TODO : shall we use the previous month limit stored in database ?
      # previous_month_limit = BureauConsultant::Value["LIMITE_DA_#{previous_month_name}"]

      if office_activity_reports.where(year: Date.current.year, month: Date.current.month).empty?
        @statement_of_activities_request_months << Date.current.end_of_month.beginning_of_month

        if previous_month.year == Date.current.year && \
           Date.current <= previous_month_limit && \
           office_activity_reports.where(year: Date.current.year, month: previous_month.month).empty?
          @statement_of_activities_request_months << previous_month
        end
      end

      @statement_of_activities_request_months.compact!
      @statement_of_activities_request_months.uniq!

      # removes months that are not allowed by the DsnCalendar
      Rails.logger.warn "DSN Office Date does not exist in database" if Goxygene::DsnCalendar.current_office_date.nil?

      @statement_of_activities_request_months.reject! do |date|
        dsn_calendar = Goxygene::DsnCalendar.find_by(year: date.year, month: date.month)
        dsn_calendar.nil? || dsn_calendar.office_date < Date.today
      end

      @statement_of_activities_request_months.sort

    end
  end
end

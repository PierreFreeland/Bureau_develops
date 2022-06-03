module BureauConsultant
  module HasStatementOfActivities # compatibility layer for bureau consultant
    extend ActiveSupport::Concern

    def current_statement_of_activities_request
      office_activity_reports.in_edition.first
    end

    def has_to_complete_current_statement_of_activities_request?
      # TODO : fix has_to_complete_current_statement_of_activities_request?
      false
      # if Date.current.day >= 20
      #   if current_statement_of_activities_request && !current_statement_of_activities_request.activities_validated?
      #     return true
      #   elsif current_statement_of_activities_request.nil? && first_possible_statement_of_activities_request_month
      #     return true
      #   end
      # end

      # false
    end

  end
end

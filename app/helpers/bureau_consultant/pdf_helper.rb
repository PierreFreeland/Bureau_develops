module BureauConsultant
  module PdfHelper
    def statement_of_operating_expenses_line_class_for(statement_of_operating_expenses_line)
      case statement_of_operating_expenses_line.status
      when 'itg_rejected' then 'text-linethrough'
      when 'itg_edited'   then 'text-red'
      when 'itg_created'  then 'text-blue'
      end
    end

    def statement_of_activities_line_class_for(statement_of_activities_line)
      case statement_of_activities_line.status
        when 'itg_rejected' then 'text-linethrough'
        when 'itg_edited'   then 'text-red'
        when 'itg_created'  then 'text-blue'
      end
    end
  end
end

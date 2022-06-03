require "base_presenter"

class StatementOfActivitiesPresenter < BasePresenter

  formater currency: %i{
             expenses_with_taxes
             gross_wage
             standard_gross_wage
             total_expenses_with_vat
             total_expenses_without_vat
             expenses_vat
             kilometer_cost
             max_expenses
           },
           number: %i{
             days_of_work
             hours
             absences_hours
             kilometers
             total_worked_days
             unpaid_absences_days
             total_days_of_work
             total_days
           }

  def formated_date
    I18n.l date, format: :month_year
  end

  def total_worked_days
    work_days + enhancement_days
  end

  def total_days
    work_days + enhancement_days + unemployment_days
  end

  def pre_calculate_filled_working_hours
    total_days * Goxygene::Parameter.daily_work_hours_max
  end

  def pre_calculate_absence_hours
    if calculated_absences_days < 17
      calculated_absences_days * Goxygene::Parameter.daily_work_hours_max
    else
      total_of_hours_da - pre_calculate_filled_working_hours
    end
  end

  def formated_max_salary
    h.number_to_currency(consultant.cumuls.max_salary_or_zero == 0 ? standard_gross_wage : consultant.cumuls.max_salary_or_zero)
  end

  def max_expenses
    value = consultant.cumuls.estimate_max_expenses - (gross_wage || standard_gross_wage) * consultant.salary_cost
    h.number_to_currency value <= 0 ? 0 : value
  end

  def total_expenses_with_vat
    expenses_with_taxes
  end

  def total_expenses_without_vat
    expenses
  end

end

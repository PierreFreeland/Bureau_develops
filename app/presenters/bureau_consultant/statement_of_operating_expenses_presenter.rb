require "base_presenter"

class StatementOfOperatingExpensesPresenter < BasePresenter

  def formated_date
    I18n.l date, format: :month_year
  end

  def formated_total_expenses_with_vat
    h.number_to_currency total_with_taxes
  end

  def formated_total_expenses_without_vat
    h.number_to_currency total
  end

  def formated_total_vat
    h.number_to_currency vat
  end

end

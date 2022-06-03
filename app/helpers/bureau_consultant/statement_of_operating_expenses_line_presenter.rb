require "base_presenter"

module BureauConsultant
  class StatementOfOperatingExpensesLinePresenter < BasePresenter

    def formated_expense_with_vat
      h.number_to_currency total_with_taxes
    end

    def formated_expense_without_vat
      h.number_to_currency total_with_taxes - vat
    end

    def formated_vat_amount
      h.number_to_currency vat
    end

  end
end

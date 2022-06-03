require "base_presenter"

module BureauConsultant
  class InvoiceRequestPresenter < BasePresenter

    def date
      invoicing_date && I18n.l(invoicing_date.to_date) rescue nil
    end

    def formated_fees
      h.number_to_currency fees,              unit: currency.symbol
    end

    def formated_expenses
      h.number_to_currency expenses,          unit: currency.symbol
    end

    def formated_total_without_vat
      h.number_to_currency total_including_taxes - vat, unit: currency.symbol
    end

    def formated_total_tva
      h.number_to_currency vat,         unit: currency.symbol
    end

    def formated_total_ttc
      h.number_to_currency total_including_taxes,         unit: currency.symbol
    end

    def formated_remaining_due
      h.number_to_currency remaining_due,     unit: currency.symbol
    end

    def formated_vat_amount
      h.number_to_currency vat,        unit: currency.symbol
    end

    def formated_total_with_vat
      h.number_to_currency total_including_taxes,    unit: currency.symbol
    end

    def status
      state.label
    end

    def formated_consultant_credit
      h.number_to_currency part_of_the_consultant
    end

  end
end
require "base_presenter"

class InvoicePresenter < BasePresenter

  formater date: %i{
    date
    target_date
  }

  def formated_fees
    h.number_to_currency fees,              unit: currency.symbol
  end

  def formated_expenses
    h.number_to_currency expenses,          unit: currency.symbol
  end

  def formated_total_without_vat
    h.number_to_currency fees + expenses, unit: currency.symbol
  end

  def formated_total_tva
    h.number_to_currency attributes['vat'],         unit: currency.symbol
  end

  def formated_total_ttc
    h.number_to_currency total_including_taxes,         unit: currency.symbol
  end

  def formated_left_to_pay_euros
    h.number_to_currency left_to_pay_euros,         unit: currency.symbol
  end

end

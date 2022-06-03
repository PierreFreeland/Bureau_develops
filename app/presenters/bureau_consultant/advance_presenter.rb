require "base_presenter"

class AdvancePresenter < BasePresenter

  def formated_date
    date && I18n.l(date.to_date) rescue nil
  end

  def formated_amount
    h.number_to_currency amount
  end

  def status
    transfer_condition.label
  end
end

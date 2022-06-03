require "base_presenter"

module BureauConsultant
  class CommercialContractRequestPresenter < BasePresenter

    def creation_date
      created_at && I18n.l(created_at.to_date) rescue nil
    end

    def sent_at
      business_contract_versions.last.sent_on && I18n.l(business_contract_versions.last.sent_on) rescue nil
    end

    def amount_without_vat
      h.number_to_currency order_amount
    end

    def amount_with_vat
      h.number_to_currency order_amount * (1 + (vat_rate.to_f / 100))
    end

    def formated_advance_payment
      h.number_to_currency advance_payment
    end

    def filescan_relative_path
      filescan.gsub(/.*\\contrat_interv\\/, '').gsub(/\\/, '/')
    end

  end
end

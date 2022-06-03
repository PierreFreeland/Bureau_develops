require "base_presenter"

module BureauConsultant
  class CommercialContractPresenter < BasePresenter

    def creation_date
      created_at && I18n.l(created_at.to_date) rescue nil
    end

    def begin_date
      business_contract_versions.last.begining_date && I18n.l(business_contract_versions.last.begining_date) rescue nil
    end

    def end_date
      business_contract_versions.last.ending_date && I18n.l(business_contract_versions.last.ending_date) rescue nil
    end

    def sent_at
      business_contract_versions.last.sent_on && I18n.l(business_contract_versions.last.sent_on) rescue nil
    end

    def amount_without_vat
      h.number_to_currency business_contract_versions.last.order_amount
    end

    def vat_rate
      business_contract_versions.last.vat_rate&.rate.to_f
    end

    def amount_with_vat
      h.number_to_currency business_contract_versions.last.order_amount.to_f * (1 + (vat_rate.to_f / 100))
    end

    def filescan_relative_path
      filescan.gsub(/.*\\contrat_interv\\/, '').gsub(/\\/, '/')
    end

  end
end

module BureauConsultant
	class ConsultantAccountsRefreshJob < ActiveJob::Base
	  # Set the Queue as Default
	  queue_as :default

	  def perform()
      return # disabled until this is re-implemented in g-oxygene

      entries = {}

      BureauConsultant::AccountingEntriesOfConsultant.all.each do |entry|
        entries[entry.tie_code.to_i] ||= {
          financial: [],
          billing:   [],
          treasury:  []
        }

        entries[entry.tie_code.to_i][:financial] << entry if entry.is_financial?
        entries[entry.tie_code.to_i][:billing]   << entry if entry.is_billing?
        entries[entry.tie_code.to_i][:treasury]  << entry if entry.is_treasury?
      end

      entries.each do |consultant_id, accounts|
        Rails.cache.write(
          "Consultant.find(#{consultant_id}).accounting_entries_of_consultants.financial.to_a", accounts[:financial], expires_in: 12.hours
        )

        Rails.cache.write(
          "Consultant.find(#{consultant_id}).accounting_entries_of_consultants.billing.to_a", accounts[:billing],     expires_in: 12.hours
        )

        Rails.cache.write(
          "Consultant.find(#{consultant_id}).accounting_entries_of_consultants.treasury.to_a", accounts[:treasury],   expires_in: 12.hours
        )
      end
	  end
	end
end

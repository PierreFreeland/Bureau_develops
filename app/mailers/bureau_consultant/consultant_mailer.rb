module BureauConsultant
  class ConsultantMailer < ApplicationMailer
    default from: Settings.bureau_consultant.admin.email

    def commercial_contract_request(commercial_contract, pdf)
      @consultant = commercial_contract.consultant
      @correspondant_employee = @consultant.correspondant_employee
      @commercial_contract = commercial_contract

      attachments["Demande de contrat - #{commercial_contract.id}.pdf"] = pdf

      mail to: @consultant.email,
           from: email_address_with_name(@correspondant_employee&.email, @correspondant_employee&.individual&.full_name),
           subject: "Votre demande de contrat commercial pour %{client}" % { client: commercial_contract.establishment&.name || 'client' }
    end
  end
end

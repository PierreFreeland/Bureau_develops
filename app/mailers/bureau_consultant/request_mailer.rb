module BureauConsultant
  class RequestMailer < ApplicationMailer
    default from: Settings.bureau_consultant.admin.email

    def statement_of_activities_request(target)
      @statement_of_activities_request = target
      @consultant                      = target.consultant

      mail to: @consultant.user.e_mail, subject: "demande de déclaration d'activité"
    end

    def invoice_request(target)
      @consultant = target.consultant

      mail to: @consultant.user.e_mail, subject: "demande de facture"
    end
  end
end

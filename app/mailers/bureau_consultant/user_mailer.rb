module BureauConsultant
  class UserMailer < ApplicationMailer
    default from: Settings.bureau_consultant.admin.email

    def contact(user, from, message)
      @message = message
      @from    = from

      mail to: user.e_mail, subject: "email de #{from.name}"
    end

  end
end

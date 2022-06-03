module BureauConsultant
  class ApplicationMailer < ActionMailer::Base
    default from: 'no-reply@itg.fr'
    layout 'mailer'

    protected

    def email_address_with_name(address, name)
      Mail::Address.new.tap do |builder|
        builder.address = address
        builder.display_name = name if name.present?
      end.to_s
    end
  end
end

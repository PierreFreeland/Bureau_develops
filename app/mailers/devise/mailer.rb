# frozen_string_literal: true

if defined?(ActionMailer)
    class Devise::Mailer < Devise.parent_mailer.constantize
      include Devise::Mailers::Helpers

      default from: Settings.goxygene.send("#{Goxygene::Parameter.value_for_group}_info")&.noreply_email  || "unknown@default.email"
      default reply_to: Settings.goxygene.send("#{Goxygene::Parameter.value_for_group}_info")&.noreply_email  || "unknown@default.email"
  
      def reset_password_instructions(record, token, opts = {})
        @token = token
        devise_mail(record, :reset_password_instructions, opts)
      end

    end
  end

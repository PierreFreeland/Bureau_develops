class DeviseMailer < ApplicationMailer
  include Devise::Mailers::Helpers

  default from: Settings.goxygene.send("#{Goxygene::Parameter.value_for_group}_info")&.noreply_email || "unknown@default.email"
  default reply_to: Settings.goxygene.send("#{Goxygene::Parameter.value_for_group}_info")&.noreply_email || "unknown@default.email"

  def reset_password_instructions_for_prospect(record, token, opts={})
    @token = token
    devise_mail(record, :reset_password_instructions_for_prospect, opts)
  end

  def reset_password_instructions_for_consultant(record, token, opts={})
    @token = token
    devise_mail(record, :reset_password_instructions_for_consultant, opts)
  end

end

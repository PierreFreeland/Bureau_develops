module Devise::Models::Recoverable
  def send_reset_password_instructions_for_consultant
    token = set_reset_password_token
    send_devise_notification(:send_reset_password_instructions_for_consultant, token, {})

    token
  end

  def send_reset_password_instructions_for_prospect
    token = set_reset_password_token
    send_devise_notification(:send_reset_password_instructions_for_prospect, token, {})

    token
  end
end

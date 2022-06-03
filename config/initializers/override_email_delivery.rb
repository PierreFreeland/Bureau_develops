class OverrideEmailDelivery
  def self.delivering_email(message)
    message.to = [ENV['OVERRIDE_EMAIL_DELIVERY_TO']]
  end
end

if ENV['OVERRIDE_EMAIL_DELIVERY_TO']
  ActionMailer::Base.register_interceptor(OverrideEmailDelivery)
end

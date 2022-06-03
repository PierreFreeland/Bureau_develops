require 'lograge/sql/extension'

Rails.application.configure do
  config.colorize_logging = false

  # Lograge config
  config.lograge.enabled = true
  config.lograge.keep_original_rails_log = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.logger = ActiveSupport::Logger.new "#{Rails.root}/log/lograge_#{Rails.env}.log"

  config.lograge.custom_payload do |controller|
    {
      remote_host: controller.request.host,
      remote_ip: controller.request.remote_ip,
      login: controller.respond_to?(:true_cas_authentication) ? controller.true_cas_authentication&.login : controller.current_cas_authentication&.login,
      impersonated_login: controller.current_cas_authentication&.login
    }
  end

  config.lograge.custom_options = ->(event) {
    {
      environment: ENV['ROLLBAR_ENV'],
      pid: Process.pid,
      hostname: Socket.gethostname,
      params: event.payload[:params],
      time: %Q('#{event.time}'),
      transaction_id: event.transaction_id#,
      # remote_ip: event.payload[:ip]

      # event.headers ?
      # connected user
      # pid
      # hostname
    }
  }

end

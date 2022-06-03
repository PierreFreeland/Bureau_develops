require 'api_payroll'

begin
  unless Rails.env.test?
    Payroll = ApiPayroll.new(
      url:    ENV['API_PAYROLL_URL']    || 'http://localhost:3334',
      key:    ENV['API_PAYROLL_KEY']    || 'alice',
      secret: ENV['API_PAYROLL_SECRET'] || 'mystic',
      authorization_token: ENV['API_PAYROLL_AUTHORIZATION_TOKEN'],
      logger: Rails.logger,
      cache:  Rails.cache
    )
  end
rescue => e
  Rails.logger.warn "could not initialize Payroll Api link : #{e}"
end

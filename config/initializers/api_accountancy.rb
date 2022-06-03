require 'api_accountancy'

begin
  # unless Rails.env.test? #remove check test env because goxygene have test it
    Accountancy = ApiAccountancy.new(
      url:    ENV['API_ACCOUNTANCY_URL']    || 'http://localhost:3333',
      key:    ENV['API_ACCOUNTANCY_KEY']    || 'alice',
      secret: ENV['API_ACCOUNTANCY_SECRET'] || 'mystic',
      logger: Rails.logger,
      cache:  Rails.cache
    )
  # end
rescue => e
  Rails.logger.warn "could not initialize Accountancy Api link : #{e}"
end



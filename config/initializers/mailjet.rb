if ENV['MAILJET_API_KEY'] && ENV['MAILJET_SECRET_KEY']

  Mailjet.configure do |config|
    config.api_key    = ENV['MAILJET_API_KEY']
    config.secret_key = ENV['MAILJET_SECRET_KEY']
  end

end
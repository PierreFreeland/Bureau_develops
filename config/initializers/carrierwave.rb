CarrierWave.configure do |config|
  # These permissions will make dir and files available only to the user running
  # the servers
  config.permissions = 0664
  config.directory_permissions = 0775
  # This avoids uploaded files from saving to public/ and so
  # they will not be available for public (non-authenticated) downloading
  config.root = Rails.root
  #

  if Rails.env.production? || (Rails.env.development? && ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY'] && ENV['AWS_S3_BUCKET_NAME'])
    config.fog_provider = 'fog/aws'

    config.fog_credentials = {
      provider:             'AWS',
      aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'] || 'changeme',
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] || 'changeme',
      region:                ENV['AWS_S3_REGION'] || 'eu-west-1'
    }

    config.fog_directory = ENV['AWS_S3_BUCKET_NAME']
    config.fog_public = false
    config.fog_authenticated_url_expiration = ENV['FOG_AUTHENTICATED_URL_EXPIRATION'] || 60

    config.storage = :fog
  else
    config.storage = :file
  end
end

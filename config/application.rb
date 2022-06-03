require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ItgHubApplicatif
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Use local Timezone
    config.time_zone = 'Paris' # Local time zone
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_attributes = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # schema.rb cannot handle enums and sequences proprely
    config.active_record.schema_format = :sql

    # Default headers : for security
    config.action_dispatch.default_headers = {
      'Content-Security-Policy' => Rails.env.production? ? "default-src 'self'; " + \
                                                           "connect-src 'self' https://www.google-analytics.com https://stats.g.doubleclick.net https://j.clarity.ms https://www.clarity.ms https://app.satismeter.com;" + \
                                                           "style-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com https://fonts.googleapis.com https://fonts.gstatic.com https://maxcdn.bootstrapcdn.com; " + \
                                                           "font-src 'self' https://maxcdn.bootstrapcdn.com https://fonts.gstatic.com https://cdnjs.cloudflare.com; " + \
                                                           "frame-src 'self' https://www.google.com;" + \
                                                           "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://widget.intercom.io https://a.clarity.ms https://j.clarity.ms https://www.googleadservices.com https://js-agent.newrelic.com https://maxcdn.bootstrapcdn.com https://cdnjs.cloudflare.com https://app.satismeter.com https://bat.bing.com https://www.google.com https://js.intercomcdn.com https://www.google-analytics.com https://snap.licdn.com https://googleads.g.doubleclick.net https://px.ads.linkedin.com https://www.googletagmanager.com https://bam.nr-data.net; " + \
                                                           "img-src 'self' https://c.clarity.ms https://px.ads.linkedin.com https://bat.bing.com https://www.google-analytics.com https://www.google.com https://www.google.fr https://img.youtube.com https://www.googletagmanager.com https://www.linkedin.com https://c.bing.com;" : '',
      'Strict-Transport-Security' => 'max-age=31536000; includeSubdomains;'
    }
  end
end

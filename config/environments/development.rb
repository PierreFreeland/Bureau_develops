Rails.application.configure do
  config.after_initialize do
    Bullet.enable        = false
    Bullet.alert         = true
    Bullet.bullet_logger = true
    Bullet.console       = true
  # Bullet.growl         = true
    Bullet.rails_logger  = true
    Bullet.add_footer    = true
  end

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Show sql log only if development
  config.lograge_sql.keep_default_active_record_log = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  config.cache_store = :dalli_store, nil, { namespace: 'itg_app', expires_in: 1.day, compress: true }

  # use sidekiq even in development mode
  config.active_job.queue_adapter = :sidekiq

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.perform_caching = false

  # Preview email in the default browser instead of sending it.
  config.action_mailer.delivery_method = :letter_opener

  config.action_mailer.asset_host = 'http://localhost:3000'

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.action_mailer.default_url_options = { host: "localhost:3000" }

  if !ENV.fetch("MAILCATCHER_ENABLED", 0).to_i.zero?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = { address: ENV.fetch("MAILCATCHER_HOST"), port: ENV.fetch("MAILCATCHER_PORT") }
  end

  config.action_controller.perform_caching = true
end

TurboSprockets.configure do |config|
  config.preloader.enabled = true
  config.precompiler.enabled = true
end

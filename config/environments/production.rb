D2mECards::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # CUSTOM SETTINGS

  #config.paypal_return_url = 'http://77.28.98.73:8202/transaction_complete'
  #config.paypal_ipn_url = 'http://77.28.98.73:8202/transaction'
  #config.paypal_cancel_url = 'http://77.28.98.73:8202/cancel_transaction'
  #config.paypal_currentcy = 'USD'
  #config.paypal_receiver_email = 'cdeyan_1338373228_biz@yahoo.com'
  #
  #config.ftp_server = 'localhost'
  #config.ftp_user = 'rails'
  #config.ftp_password = 'r@1L5l0l'
  #config.ftp_swf_dir = '/artiphany_assets/ecard_swfs/'
  #config.ftp_images_dir = '/artiphany_assets/ecard_images/'
  #config.ftp_videos_dir = '/artiphany_assets/ecard_videos/'
  #config.ftp_artiphany_assets_dir = '/artiphany_assets/'
  #
  #config.video_files_url = 'http://77.28.98.73:8202/animations/'
  #
  #config.email_from = 'webcomposer.info@gmail.com'
  #config.email_return_path = 'system@example.com'
  #config.email_bcc = ['cdejan@gmail.com', 'webcomposer.info@gmail.com']
  #config.email_support = 'webcomposer.info@gmail.com'

  # END OF CUSTOM SETTINGS

  config.paypal_return_url = 'http://77.28.98.73:8202/transaction_complete'
  config.paypal_ipn_url = 'http://77.28.98.73:8202/transaction'
  config.paypal_cancel_url = 'http://77.28.98.73:8202/cancel_transaction'
  config.paypal_currentcy = 'USD'
  config.paypal_receiver_email = 'cdeyan_1338373228_biz@yahoo.com'

  config.ftp_server = 'ftp.simplecustomsolutions.com'
  config.ftp_user = 'ipalladino'
  config.ftp_password = 'ip8801ip'
  config.ftp_swf_dir = '/simplecustomsolutions.com/artiphany_assets/ecard_swfs/'
  config.ftp_images_dir = '/simplecustomsolutions.com/artiphany_assets/ecard_images/'
  config.ftp_videos_dir = '/simplecustomsolutions.com/artiphany_assets/ecard_videos/'
  config.ftp_artiphany_assets_dir = '/simplecustomsolutions.com/artiphany_assets/'

  config.video_files_url = 'http://www.simplecustomsolutions.com/animations/'

  config.email_from = 'no-reply@artiphany.com'
  config.email_return_path = 'system@example.com'
  config.email_bcc = ['cdejan@gmail.com', 'webcomposer.info@gmail.com']
  config.email_support = 'webcomposer.info@gmail.com'
end

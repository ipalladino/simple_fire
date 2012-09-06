D2mECards::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # CUSTOM SETTINGS

  config.paypal_return_url = 'http://77.28.98.73:8201/transaction_complete'
  config.paypal_ipn_url = 'http://77.28.98.73:8201/transaction'
  config.paypal_cancel_url = 'http://77.28.98.73:8201/cancel_transaction'
  config.paypal_currentcy = 'USD'
  config.paypal_receiver_email = 'cdeyan_1338373228_biz@yahoo.com'

  config.ftp_server = '77.28.98.73'
  config.ftp_user = 'rails'
  config.ftp_password = 'myR0rPwd'
  config.ftp_swf_dir = '/artiphany_assets/ecard_swfs/'
  config.ftp_images_dir = '/artiphany_assets/ecard_images/'
  config.ftp_videos_dir = '/artiphany_assets/ecard_videos/'
  config.ftp_artiphany_assets_dir = '/artiphany_assets/'

  config.video_files_url = 'http://77.28.98.73:8201/animations/'

  config.email_from = 'webcomposer.info@gmail.com'
  config.email_return_path = 'system@example.com'
  config.email_bcc = ['cdejan@gmail.com', 'webcomposer.info@gmail.com']
  config.email_support = 'webcomposer.info@gmail.com'

  # END OF CUSTOM SETTINGS

end

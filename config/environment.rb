# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
D2mECards::Application.initialize!

# TODO: Remove all lines bellow...
## Ensure the gateway is in test mode
##ActiveMerchant::Billing::Base.gateway_mode = :test
#PAYPAL_ACCOUNT = 'busine_1333086758_biz@simplecustomsolutions.com'
#ActiveMerchant::Billing::Base.mode = :test
#ActiveMerchant::Billing::Base.integration_mode = :test
#ActiveMerchant::Billing::PaypalGateway.pem_file = File.read(File.dirname(__FILE__) + '/../paypal/paypal_cert.pem')
#
##unless RAILS_ENV == 'production'
##  PAYPAL_ACCOUNT = 'busine_1333086758_biz@simplecustomsolutions.com'
##  ActiveMerchant::Billing::Base.mode = :test
##else
#  #PAYPAL_ACCOUNT = 'paypalaccount@example.com'
##  PAYPAL_ACCOUNT = 'busine_1333086758_biz@simplecustomsolutions.com'
##end

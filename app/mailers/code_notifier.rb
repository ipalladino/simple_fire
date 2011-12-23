class CodeNotifier < ActionMailer::Base
  default :from => 'no-reply@artiphany.com',
          :return_path => 'system@example.com'

  def welcome(recipient)
    @account = recipient
    mail(:to => recipient[:email],
         :subject => "You just purchased an eCard from Artiphany, inside you will find your redeemable code",
         :bcc => ["ignacio@simplecustomsolutions.com", "Order Watcher <gabriel@simplecustomsolutions.com>"])
  end
  
  def recipient(content)
    @content = content
    name = content[:sendername]
    messagesubject = name + " just send you an Artiphany eCard"
    mail(:to => content[:email],                                          
         :bcc => ["ignacio@simplecustomsolutions.com", "Order Watcher <gabriel@simplecustomsolutions.com>"],
         :subject => messagesubject)  
  end
end


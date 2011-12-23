class CodeNotifier < ActionMailer::Base
  default :from => 'no-reply@artiphany.com',
          :return_path => 'system@example.com'

  def welcome(recipient)
    @account = recipient
    mail(:to => recipient[:email],
         :subject => "You just purchased an eCard from Artiphany, inside you will find your redeemable code",
         :bcc => ["bcc@example.com", "Order Watcher <gabriel@simplecustomsolutions.com>"])
  end
  
  def recipient(content)
    @content = content
    name = content[:sendername]
    messagesubject = name + " just sent you an eCard through Artiphany"
    mail(:to => content[:email],                                          
         :bcc => [content[:senderemail], "Order Watcher <gabriel@simplecustomsolutions.com>"],
         :subject => messagesubject)  
  end
end


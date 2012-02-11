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
    messagesubject = name + " just sent you an Artiphany eCard"
    mail(:to => content[:email],
         :from => name + " <" + content[:senderemail] + ">",
         :bcc => ["ignacio@simplecustomsolutions.com", "Order Watcher <gabriel@simplecustomsolutions.com>"],
         :subject => messagesubject)  
  end
  
  def support_mail(content)
    @content = content
    name = content[:name]
    email = content[:email]
    message = content[:message]
    subject = "Support request from " + email
    mail(:to => "ignacio@simplecustomsolutions.com",
         :subject => subject
    )
  end
    
end


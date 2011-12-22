class CodeNotifier < ActionMailer::Base
  default :from => 'no-reply@artiphany.com',
          :return_path => 'system@example.com'

  def welcome(recipient)
    @account = recipient
    mail(:to => recipient[:email],
         :bcc => ["bcc@example.com", "Order Watcher <gabriel@simplecustomsolutions.com>"])
  end
  
  def recipient(content)
    message = "You just received an eCard from " + content[:sendername]
    @content = content
    mail(:to => content[:email],                                          
         :bcc => [content[:senderemail], "Order Watcher <gabriel@simplecustomsolutions.com>"],
         :subject => message)  
  end
end


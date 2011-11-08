class CodeNotifier < ActionMailer::Base
  default :from => 'no-reply@artiphany.com',
          :return_path => 'system@example.com'

  def welcome(recipient)
    @account = recipient
    mail(:to => recipient[:email],
         :bcc => ["bcc@example.com", "Order Watcher <watcher@example.com>"])
  end
  
  def recipientecardnotification(content)
    @content = content
    mail(:to => content[:email],                                          
         :bcc => [content[:senderemail], "Order Watcher <ipalladino@gmail.com>"])  
  end
end


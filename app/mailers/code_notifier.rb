class CodeNotifier < ActionMailer::Base
  default :from => Rails.application.config.email_from,
          :return_path => Rails.application.config.email_return_path

  def welcome(recipient)
    @account = recipient
    mail(:to => recipient[:email],
         :subject => "You just purchased an eCard from Artiphany, inside you will find your redeemable code",
         :bcc => Rails.application.config.email_bcc)
  end
  
  def recipient(content)
    @content = content

    messagesubject = content[:sendername] + " just sent you an Artiphany eCard"

    mail(:to => content[:email],
         :from => content[:sendername] + " <" + content[:senderemail] + ">",
         :bcc => Rails.application.config.email_bcc,
         :subject => messagesubject)
  end
  
  def support_mail(content)
    @content = content
    name = content[:name]
    email = content[:email]
    message = content[:message]
    subject = "Support request from " + email
    mail(:to => Rails.application.config.email_support,
         :subject => subject
    )
  end
    
end


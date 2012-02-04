require 'shopify_api'
require 'logger'
require 'rexml/document'
require 'xmlsimple'
require 'digest'

class EcardOrdersController < ApplicationController
  def new
  end
  
  def sendBackerEmail
    
  end
  
  def autoredeem
    code = params[:code]
    recipient_name = params[:recipient_name]
    recipient_email = params[:recipient_email]
    sender_name = params[:sender_name]
    sender_email = params[:sender_email]
    message1 = params[:message1]
    message2 = params[:message2]
    ecard_variant_id = params[:ecard_variant_id]
    imageurl = params[:image]

    found = false
    ecard_id = 0
    e = Ecard.new
    o = EcardOrder.new
    
    #users_ecard = cookies[:ecard][0]
    users_ecard = {:email => cookies[:ecardemail], :card_id => cookies[:ecardid]}
    puts 'user email saved on cookie:' + users_ecard[:email]
    
    if(users_ecard != nil)
      puts 'Cookie found'
      ordered_ecard = EcardOrder.find :all, :conditions => ['email = ? AND sent = ?', users_ecard[:email], false]
      if ordered_ecard[0] != nil
        puts 'Order found, email match'
        ecard = Ecard.find_by_id(ordered_ecard[0].ecard_id)
        if ecard != nil
          puts 'Ecard found'
          if ecard.variant_id.to_i == users_ecard[:card_id].to_i
            puts 'Ecard variant and user variant matches'
            e = ecard
            o = ordered_ecard[0]
            found = true
            ecard_id = ecard.id
          end 
        end
      end
      
      if found
        link = new_secure_link("#{Time.now.utc}--#{recipient_email}")
        sent_ecard = SentEcard.create(:recipientemail => recipient_email,
                                      :recipientname => recipient_name,
                                      :message1 => message1,
                                      :message2 => message2,
                                      :nametoshow => sender_name,
                                      :senderemail => sender_email,
                                      :ecard_id => ecard_id,
                                      :securelink => link)
        o.sent = true
        o.save
        
        
        #here I would send the email
        puts "attemping to send email"
        content = {:email => recipient_email, 
                   :recipient_name => recipient_name, 
                   :link => link,
                   :senderemail => sender_email,
                   :sendername => sender_name,
                   :image => imageurl}
        CodeNotifier.recipient(content).deliver

        render :nothing => true
      else
        redeem_code_failed
      end
    else 
      not_found
    end
  end
  
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
  
  def transactionsuccess
    recipient_email = cookies[:recipient_email]
    #cookies[:imageurl] = { :value => imageurl, :expires => 1.hour.from_now }
    
    puts "****************************************"
    puts "Attemping to find cookies"
    puts "****************************************"
    
    if(recipient_email != nil)
      cookies.delete :recipient_email
      @message = "Thank you for your purchase!! \n
  		We sent you an email with the details of your purchase, and we already took care of sending your ecard.
  		Feel free to continue shopping with us"
  		
      puts "****************************************"
      puts "Cookie found, preparing to send email"
      puts "****************************************"
        
      @image = cookies[:imageurl]||= "http://artiphany.herokuapp.com/assets/logo1-5de2b0b0dd853c9cc3fdd9c1cbb1b02c.png"
      link = new_secure_link("#{Time.now.utc}--#{recipient_email}")
      sent_ecard = SentEcard.create(:recipientemail => cookies[:recipient_email],
                                  :recipientname => cookies[:recipient_name],
                                  :message1 => cookies[:message1],
                                  :message2 => cookies[:message2],
                                  :nametoshow => cookies[:sender_name],
                                  :senderemail => cookies[:sender_email],
                                  :ecard_id => cookies[:ecard_variant_id],
                                  :securelink => link)

      puts "attemping to send email"
      content = {:email => cookies[:recipient_email], 
                 :recipient_name => cookies[:recipient_name], 
                 :link => link,
                 :senderemail => cookies[:sender_email],
                 :sendername => cookies[:sender_name],
                 :image => cookies[:imageurl]}
      CodeNotifier.recipient(content).deliver
    else
      @message = "Your ecard was already sent, thank you!"
      redirect_to "http://artiphany.herokuapp.com/"
    end
  end
  
  
  def handleorder

    logger = Logger.new('logfile.log')
    logger.info('initialize...recieved webhook') { request.body }
    found = false
    ecard = Ecard.new
    
    #parse order xml
    order = XmlSimple.xml_in(request.body)
    
    #check if financial status is paid/authorized
    if order['financial-status'][0] == 'paid' or order['financial-status'][0] == 'authorized'
      #generate random code
      aemail = order['email'][0]
      puts "email from xml:" + aemail
      code = new_secure_link("#{Time.now.utc}--#{aemail}")
      puts "new code:" + code
      items = ''
      #look for ecards on the order
      order['line-items'][0]['line-item'].each do |item|

        items << "variant_id: " + String(item['variant-id'][0]['content']) + " "
        variant_id = item['variant-id'][0]['content']
        puts items
        puts "Attemping to find Ecard with id 1..."
        #if ecard = Ecard.find_by_variant_id(variant_id)
        #if(ecard = Ecard.find :all, :conditions => ['variant_id = ?', variant_id])
        ecard = Ecard.find_by_variant_id(variant_id)
    
        if(ecard != nil)

          #EcardOrder.find :all, :order => 'id DESC', :conditions => ['code = ? AND sent = ?', code, false]
          #create an entry on our db with the code and ecard
          ecardorder = EcardOrder.create(:ecard_id => ecard.id, :code => String(code), :sent => false, :email => aemail)
          items << "Added card:" + String(ecard.variant_id) + " with the code:" + String(code) + "--"
          puts ecard.variant_id

          found = true
        end

      end
    end
    
    #if a code was created send it
    if found
      user = {:email => order['email'][0], :name => order['email'][0], :code => code}
      CodeNotifier.welcome(user).deliver
    end

    render :nothing => true
  end
  
  def redeemcode
    code = params[:code]
    recipient_name = params[:recipient_name]
    recipient_email = params[:recipient_email]
    sender_name = params[:sender_name]
    sender_email = params[:sender_email]
    message1 = params[:message1]
    message2 = params[:message2]
    ecard_variant_id = params[:ecard_variant_id]
    
    #STUB
    #code = "123"
    #recipient_name = "recipient_name"
    #recipient_email = "recipient@email.com"
    #sender_name = "sender_name"
    #sender_email = "sender@email.com"
    #message1 = "message1"
    #message2 = "message2"
    #ecard_variant_id = "ecard_variant_id"

    found = false
    ecard_id = 0
    e = Ecard.new
    o = EcardOrder.new
    
    
    #check code for redeemable ecards
    if(ordered_ecards = EcardOrder.find :all, :order => 'id DESC', :conditions => ['code = ? AND sent = ?', code, false])
      pp ordered_ecards
      #loop through redeemable cards with that code
      ordered_ecards.each do |ordered_ecard|  
        #look for the ecard associated with the ecard_id on the order
        ecard = Ecard.find_by_id(ordered_ecard.ecard_id)
        pp ecard
        if ecard != nil       
          if ecard.variant_id.to_i == ecard_variant_id.to_i
            e = ecard
            o = ordered_ecard
            found = true
            pp "Variant matched order variant"
            pp o
            ecard_id = ecard.id
          end
        end
      end
      
      #if the equivalent variant_id with the order was found create a sent_ecard and send email
      if found
        link = new_secure_link("#{Time.now.utc}--#{recipient_email}")
        sent_ecard = SentEcard.create(:recipientemail => recipient_email,
                                      :recipientname => recipient_name,
                                      :message1 => message1,
                                      :message2 => message2,
                                      :nametoshow => sender_name,
                                      :senderemail => sender_email,
                                      :ecard_id => ecard_id,
                                      :securelink => link)
        o.sent = true
        o.save
        
        #here I would send the email
      end
    end
    
    if(code == "birdseed" or code == "narwhal")
      link = new_secure_link("#{Time.now.utc}--#{recipient_email}")
      #look for the ecard associated with the ecard_id on the order
      ecard = Ecard.find_by_variant_id(ecard_variant_id)
      if ecard != nil       
        ecard_id = ecard.id
      end
      
      sent_ecard = SentEcard.create(:recipientemail => recipient_email,
                                    :recipientname => recipient_name,
                                    :message1 => message1,
                                    :message2 => message2,
                                    :nametoshow => sender_name,
                                    :senderemail => sender_email,
                                    :ecard_id => ecard_id,
                                    :securelink => link)
      o.sent = true
      o.save
      found = true
    end
    pp "If we found the order and did all our staff go into the email sending code"
    if found
      pp "All went OK, was found, about to send email"
      content = {:email => recipient_email, 
                 :recipient_name => recipient_name, 
                 :link => link,
                 :senderemail => sender_email,
                 :sendername => sender_name}
      CodeNotifier.recipient(content).deliver

      render :text => "Order found: email sent"
    else
      #render :text => "404: Order not found or already used" + String(found)
      redeem_code_failed
    end
  end
  
  def redeem_code_failed
    raise ActionController::RoutingError.new('The code is not valid')
  end
  
  def new_secure_link(string)
    Digest::SHA2.hexdigest(string)
  end
  
  def viewecard
    @code = params[:ecard]
  end
  
  def requestmessages
    code = params[:code]
    sentecard = SentEcard.find_by_securelink(code)
    e = Ecard.find_by_id(sentecard.ecard_id)
    if(sentecard != nil)
      j = ActiveSupport::JSON
      render :json => j.encode(sentecard)
    else
      render :text => "Failed"
    end
  end

end

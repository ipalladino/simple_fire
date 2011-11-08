require 'shopify_api'
require 'logger'
require 'rexml/document'
require 'xmlsimple'
require 'digest'

class EcardOrdersController < ApplicationController
  def new
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
                   :sendername => sender_name}
        CodeNotifier.recipient(content).deliver

        render :text => "Order found: email sent code automatically redeemed"
      else
        redeem_code_failed
      end
    else 
      render :text => '404: user data not present'
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

    render :text => items
    #render :text => 'ok'
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
        break if found == true  
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
    if found
      content = {:email => recipient_email, 
                 :recipient_name => recipient_name, 
                 :link => link,
                 :senderemail => sender_email,
                 :senderemail => sender_email}
      CodeNotifier.recipientecardnotification(content).deliver

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
  

end

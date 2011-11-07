require "net/http"
require "uri"
require 'open-uri'
require 'shopify_api'
require 'mechanize'
require 'logger'
require 'rexml/document'
require 'xmlsimple'


class PagesController < ApplicationController

  def home
    @title = "Home"
  end

  def contact
    @title = "Contact"
  end

  def about
    @title = "About"
  end
  
  def help
    @title = "Help"
  end
  def app
    @title = "Application"
  end
  
  def handleorder
    logger = Logger.new('logfile.log')
    logger.info('initialize...recieved webhook') { request.body }
    
    items = ''
    
    #parse order xml
    order = XmlSimple.xml_in(request.body)
    
    #check if financial status is paid/authorized
    if order['financial-status'][0] == 'paid' or order['financial-status'][0] == 'authorized'    
      #check if the user exists on our DB
      sender_email = order['email'][0]
      if sender = Sender.find_by_email(sender_email)
        #look for ecards
        #ecards = Ecard.find_by_sender_id(sender.id)
        ecards = Ecard.find :all, :order => 'id DESC',
            :conditions => ['sender_id = ?',sender.id]
      else
        #do nothing because the sender has not been registered
      end
      
    end
    
    #order['line-items'][0]['line-item'].each do |item|
    #  items << item['name'][0] + " and "
    #end
    #item = order['line-items'][0]
    #render :json => order['line-items']
    #render :json => item['line-item']
    #render :text => order['financial-status'][0]
    render :text => ecards.count
  end
  
  def addToCart 
    ### STUB INFO
    sender_email = "nachito@gmail.com"
    sender_name = 'Ignacio Palladino'
    recipient_email = "some@hotmail.com"
    recipient_name = "Nachito"
    variant_id = 141661592
    message1 = "message1"
    message2 = "message2"
    
    ### STORE NEW ECARD
    results = ''
    #Check if exists and if not Create the sender item
    if sender = Sender.find_by_email(sender_email)
      #add the ecard with this sender_id
      
      ecard = Ecard.create(:recipient_email => recipient_email, 
                           :recipient_name => recipient_name, 
                           :message1 => message1, 
                           :message2 => message2,
                           :sender_id => sender.id,
                           :sent => false,
                           :variant_id => variant_id)
      
      results << 'Sender found, name:' + sender.name  + '--- proceed'  + '/n/trecipient_email:' + ecard.recipient_email + 'sent:' + String(ecard.sent)
    else
      #create sender
      results << 'Sender not found --- creating'
      sender = Sender.create(:email => sender_email, :name => sender_name)
      
      #add the ecard with the sender_id
      ecard = Ecard.create(:recipient_email => recipient_email, 
                           :recipient_name => recipient_name, 
                           :message1 => message1, 
                           :message2 => message2,
                           :sender_id => sender.id,
                           :sent => false,
                           :variant_id => variant_id)
      
      results << '\n User created, \n\temail:'+sender.email+'\n\tname:'+sender.name+'\n\trecipient_email:'+ecard.recipient_email+'sent:'+ String(ecard.sent)
    end
    
    
    render :text => results
    
    #agent = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Mozilla' }
    #page = agent.get 'http://simple-fire-1105.herokuapp.com/'
    #add_to_cart_form = page.form_with(:action => 'http://leuschke-inc8683.myshopify.com/cart/add')
    #add_to_cart_form['id'] = '141661592'
    #add_to_cart_form['return_to'] = 'http://leuschke-inc8683.myshopify.com/checkout'
    #page = agent.submit add_to_cart_form
    #render :text => page.body
    
  end
  
  def getproducts    
    api = "1c407a7cf65eb1c79a9a1883830be87b"
    password = "90fc2c2816609950da97db0135806369"
    http = Net::HTTP.new('leuschke-inc8683.myshopify.com')
    #http.use_ssl = true
    http.start do |http|
      req = Net::HTTP::Get.new('/admin/products.json')
      # we make an HTTP basic auth by passing the
      # username and password
      req.basic_auth api, password
      resp, data = http.request(req)
      render :json => data 
    end    
  end
  
end

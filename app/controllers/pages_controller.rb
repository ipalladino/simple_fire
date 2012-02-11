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
  
  def support
    @title = "Support"
    
    if params[:name] !=nil
      
      if params[:name] != "" and params[:email] != "" and params[:message] != ""
        
        @message = "Thank you, your message has been sent."
        content = {
          :name => params[:name],
          :email => params[:email],
          :message => params[:message]
        }
        CodeNotifier.support_mail(content).deliver
      else
        @message = "You need to fill all the fields, thank you."
      end
    else
      @message = ""
    end
    
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
  
  def testnewapp
    @title = "Test new app"
  end
  
  def viewcookie
    
    render :text => 'Cookie successfully set: email is' + cookies[:ecardemail] + " and the id is " + cookies[:ecardid]
  end
  
  def paywithpaypal 
    #email = params[:email]    
    #variant_id = params[:item]
    #imageurl = params[:image]
    
    recipient_name = params[:recipient_name]
    recipient_email = params[:recipient_email]
    sender_name = params[:sender_name]
    sender_email = params[:sender_email]
    message1 = params[:message1]
    message2 = params[:message2]
    ecard_variant_id = params[:ecard_variant_id]
    imageurl = params[:image]
    
    cookies[:recipient_name] = { :value => recipient_name, :expires => 1.hour.from_now }
    cookies[:recipient_email] = { :value => recipient_email, :expires => 1.hour.from_now }
    cookies[:sender_name] = { :value => sender_name, :expires => 1.hour.from_now }
    cookies[:sender_email] = { :value => sender_email, :expires => 1.hour.from_now }
    cookies[:message1] = { :value => message1, :expires => 1.hour.from_now }
    cookies[:message2] = { :value => message2, :expires => 1.hour.from_now }
    cookies[:ecard_variant_id] = { :value => ecard_variant_id, :expires => 1.hour.from_now }
    cookies[:imageurl] = { :value => imageurl, :expires => 1.hour.from_now }
    
    @image = imageurl
    #@item = ecard_variant_id
  end
  
  def addtocart 
    email = params[:email]
    #card_id = '141661592'
    
    variant_id = params[:item]
    imageurl = params[:image]
    
    cookies[:ecardemail] = { :value => email, :expires => 1.hour.from_now }
    
    cookies[:ecardid] = { :value => variant_id, :expires => 1.hour.from_now }
    @image = imageurl
    @item = variant_id
    
    #a = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Mozilla' }
    #page = a.get 'http://simple-fire-1105.herokuapp.com/'
    #add_to_cart_form = page.form_with(:action => 'http://leuschke-inc8683.myshopify.com/cart/add')
    #add_to_cart_form['id'] = '141661592'
    #add_to_cart_form['return_to'] = 'http://leuschke-inc8683.myshopify.com/checkout'
    #page = a.submit add_to_cart_form
    #c = a.cookies.collect {|c| {:name => c.name, :value => c.value}}
    #c.each do |cc|
      #puts "Cookie name: " + cc[:name]
      #puts "Cookie value: " + cc[:value]
      #puts "Cookie domain: " + cc[:domain]
      #response.set_cookie(cc[:name], {:value => cc[:value], :domain => "leuschke-inc8683.myshopify.com", :path => '/'})
      #response.set_cookie(cc[:name], {:value => cc[:value]})
    #end
    
    #render :text => 'Cookie successfully set: email is' + cookies[:ecardemail]
  end
  
  def getproducts    
    api = "80a9b470d0dd9ac4628c98f093a6d758"
    password = "79a34b79f0dbafa7327581d04535f8a7"
    http = Net::HTTP.new('artiphany.myshopify.com')
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
  
  def do_special_request
    recipient_name = params[:recipient_name]
    recipient_email = params[:recipient_email]
    sender_name = params[:sender_name]
    sender_email = params[:sender_email]
    message1 = params[:message1]
    message2 = params[:message2]
    ecard_variant_id = params[:ecard_variant_id]
    imageurl = params[:image]
    
    data = [:recipient_name => recipient_name,
            :recipient_email => recipient_email,
            :sender_name => sender_name,
            :sender_email => sender_email]
    
    cookies[:recipient_name] = { :value => recipient_name, :expires => 1.hour.from_now }
    cookies[:recipient_email] = { :value => recipient_email, :expires => 1.hour.from_now }
    cookies[:sender_name] = { :value => sender_name, :expires => 1.hour.from_now }
    cookies[:sender_email] = { :value => sender_email, :expires => 1.hour.from_now }
    cookies[:message1] = { :value => message1, :expires => 1.hour.from_now }
    cookies[:message2] = { :value => message2, :expires => 1.hour.from_now }
    cookies[:ecard_variant_id] = { :value => ecard_variant_id, :expires => 1.hour.from_now }
    cookies[:imageurl] = { :value => imageurl, :expires => 1.hour.from_now }

    #data = "All vars loaded succesfully"
    render :xml => data
  end
  
end

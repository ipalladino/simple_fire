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
  
  def viewcookie
    
    render :text => 'Cookie successfully set: email is' + cookies[:ecardemail] + " and the id is " + cookies[:ecardid]
  end
  
  def addToCart 
    email = 'ipalladino@gmail.com'
    card_id = '141661592'    
  
    cookies[:ecardemail] = { :value => email, :expires => 1.hour.from_now }
    
    cookies[:ecardid] = { :value => card_id, :expires => 1.hour.from_now }
    
    render :text => 'Cookie successfully set: email is' + cookies[:ecardemail]
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

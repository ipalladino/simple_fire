require "net/http"
require "uri"
require 'open-uri'
require 'shopify_api'


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
  
  def addToCart    
    #url = URI.parse('http://leuschke-inc8683.myshopify.com/cart/add')
    #req = Net::HTTP::Post.new('/cart/add')
    #req.body = 'id=141661592'
    #res = Net::HTTP.new('leuschke-inc8683.myshopify.com').start {|http| http.request(req) }
    #case res
    #when Net::HTTPSuccess, Net::HTTPRedirection
    #  #OK
    #else
    #  res.error!
    #end  
    #render :text => "Response #{res.body}"
    body = "id=141661592"
    
    http = Net::HTTP.new('leuschke-inc8683.myshopify.com')
    http.start do |http|
        req = Net::HTTP::Post.new('/cart/add')
        req.body = body
        req.set_form_data({'variant_ID' => '141661592'})
        resp, data = http.request(req)
        render :text => data
    end
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

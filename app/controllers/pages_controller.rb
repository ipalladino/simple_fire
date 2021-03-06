require "net/http"
require "uri"
require 'open-uri'
require 'shopify_api'
require 'mechanize'
require 'logger'
require 'rexml/document'
require 'xmlsimple'
require 'paypal_adaptive'

class PagesController < ApplicationController

  def home
    @title = "Home"
  end
  
  
  def support_request_sent
    @title = "Your support request has been sent"
    @message = "Mr O'hare is analyzing your request as we speak. He will get back to you in less than 24 hours"
    @thank_you = "Thank you for choosing us!"
  end
  
  def  get_encrypted_data
    params[:price]
  end
  
  def login_form
    @link = params[:previous_page]
  end
  
  def testdesign
    
  end
  
  def checkout
    @recipient_name = params[:recipient_name]
    @recipient_email = params[:recipient_email]
    @sender_name = params[:sender_name]
    @sender_email = params[:sender_email]
    @message1 = params[:message1]
    @image = params[:image]
    @ecard_id = params[:ecard_id]
    e = Ecard.find_by_id(@ecard_id)
    if(e != nil)  
      @price = e.price
    
      return_url = Rails.application.config.paypal_return_url
      ipn_url = Rails.application.config.paypal_ipn_url
      cancel_url = Rails.application.config.paypal_cancel_url
    
      pay_request = PaypalAdaptive::Request.new
          data = {
            "returnUrl" => return_url,
            "requestEnvelope" => {"errorLanguage" => "en_US"},
            "currencyCode" => Rails.application.config.paypal_currentcy,
            "receiverList" =>
                    { "receiver" => [
                      {"email" => Rails.application.config.paypal_receiver_email, "amount"=> @price}
                    ]},
            "cancelUrl" => cancel_url,
            "actionType" => "PAY",
            "ipnNotificationUrl" => ipn_url,
          }
        #To do chained payments, just add a primary boolean flag:{“receiver”=> [{"email"=>"PRIMARY", "amount"=>"100.00", "primary" => true}, {"email"=>"OTHER", "amount"=>"75.00", "primary" => false}]}

      pay_response = pay_request.pay(data)  
      #parsed_json = ActiveSupport::JSON.decode(pay_response)  
      #puts parsed_json
      puts YAML::dump(pay_response)
      pay_key = pay_response["payKey"]
      

      if pay_response.success?
            # Send user to paypal
        link = new_secure_link("#{Time.now.utc}--#{@recipient_email}")
        
        sent_ecard = SentEcard.create(
                        :recipientemail => @recipient_email,
                        :recipientname => @recipient_name,
                        :message1 => @message1,
                        :message2 => "",
                        :nametoshow => @sender_name,
                        :senderemail => @sender_email,
                        :ecard_id => @ecard_id,
                        :securelink => link,
                        :sent => false,
                        :pay_key => pay_key
        )
        redirect_to pay_response.approve_paypal_payment_url
      else
        puts pay_response.errors.first['message']
        #redirect_to "/", notice: "Something went wrong. Please contact support."
      end
    end
  end
  
  
  def transaction
    # Create a notify object we must
    #notify = Paypal::Notification.new(request.raw_post)
    ipn = PaypalAdaptive::IpnNotification.new
    ipn.send_back(request.raw_post)

    if ipn.verified?
      puts "IT WORKED"
      if params[:pay_key] != nil
        puts "pay_key exists: continue..."
        pay_key = params[:pay_key]
        e = SentEcard.find_by_pay_key(pay_key)
        
        puts "we found something:" + e.securelink
        unless e == nil && params[:pay_key] == nil
          puts "ecard order exists: continue ..."
          ecard = Ecard.find_by_id(e.ecard_id)
          puts "ecard:" + ecard.title
          e.update_attributes(:sent => true)
          puts "attemping to send email"
          puts "email:#{e.recipientemail}"
          puts "recipient_name:#{e.recipientname}"
          puts "link:#{e.securelink}"
          puts "senderemail:#{e.senderemail}"
          puts "sendername:#{e.nametoshow}"
          puts "image:#{ecard.image}"

          recipients = e.recipientemail.split(",")
          names = e.recipientname.split(",")

          emails = []

          recipients.each_with_index do |recip, idx|
            if names[idx] != nil then
              emails << "#{names[idx].strip} <#{recip.strip}>"
            else
              emails << recip.strip
            end
          end

          content = {
            :link => e.securelink,
            :senderemail => e.senderemail,
            :sendername => e.nametoshow,
            :image => ecard.image,
            :email => emails.join(", "),
            :recipient_name => names
          }

          CodeNotifier.recipient(content).deliver
        end
      end
    else
      puts "IT DIDNT WORK"
    end

    render :nothing => true, :status => :ok
  end

  
  
  def support
    @title = "Support"
    @conditional = "if(this.value == 'Insert your message here') { this.value = ''; }"
    if params[:name] !=nil
      
      if params[:name] != "" and params[:email] != "" and params[:message] != ""
        
        @message = "Thank you, your message has been sent."
        content = {
          :name => params[:name],
          :email => params[:email],
          :message => params[:message]
        }
        CodeNotifier.support_mail(content).deliver
        # DELETE ME: redirect_to "http://artiphany.herokuapp.com/support_request_sent"
        redirect_to :action => :support_request_sent
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
    redirect_mobile("/demo_arti/demo.html")
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
    p "Setting API and PASS"
    api = "80a9b470d0dd9ac4628c98f093a6d758"
    password = "79a34b79f0dbafa7327581d04535f8a7"
    http = Net::HTTP.new('artiphany.myshopify.com')
    #http.use_ssl = true
    http.start do |http|
      p "Trying to connect to shopify"
      p req = Net::HTTP::Get.new('/admin/products.json')
      # we make an HTTP basic auth by passing the
      # username and password
      p req.basic_auth api, password
      resp, data = http.request(req)
      puts "Response #{resp.code} #{resp.message}:
                #{resp.body}"
      #puts YAML::dump(resp)
      render :json => resp.body
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
  
  def redirect_mobile(url = "/view_ecard_mobile")
    redirect_to url if /android.+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.match(request.user_agent) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|e\-|e\/|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(di|rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|xda(\-|2|g)|yas\-|your|zeto|zte\-/i.match(request.user_agent[0..3])
  end
  
  def new_secure_link(string)
    Digest::SHA2.hexdigest(string)
  end

  def e
    render :text => "Rails env: #{Rails.env}"
  end
  
end


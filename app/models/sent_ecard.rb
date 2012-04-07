class SentEcard < ActiveRecord::Base
  belongs_to :ecard
  
  attr_accessible :recipientemail , :recipientname, :message1, :message2, :nametoshow, :senderemail, :securelink, :ecard_id  , :sent, :pay_key
  
end

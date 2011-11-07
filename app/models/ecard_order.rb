class EcardOrder < ActiveRecord::Base
  belongs_to :ecard
  
  attr_accessible :code, :ecard_id, :sent
end

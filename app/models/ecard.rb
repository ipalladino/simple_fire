class Ecard < ActiveRecord::Base
  has_many :ecardorders
  attr_accessible :filename, :variant_id, :video_file, :title, :description, :image, :price
end
class AddDescTitlePriceVideoImageToEcards < ActiveRecord::Migration
  def change
    add_column :ecards, :description, :string
    add_column :ecards, :title, :string
    add_column :ecards, :price, :float
    add_column :ecards, :video_file, :string
    add_column :ecards, :image, :string
  end
end

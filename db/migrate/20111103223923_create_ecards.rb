class CreateEcards < ActiveRecord::Migration
  def change
    create_table :ecards do |t|
      t.string :filename
      t.integer :variant_id
      
      t.timestamps
    end
  end
end
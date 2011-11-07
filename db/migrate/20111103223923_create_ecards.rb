class CreateEcards < ActiveRecord::Migration
  def change
    create_table :ecards do |t|
      t.string :filename
      t.integer :variant_id
      
      t.timestamps
    end
    Ecards.create :filename => "mermaid.swf", :variant_id => 141661592
  end
end
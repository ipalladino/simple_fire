class CreateEcardOrders < ActiveRecord::Migration
  def change
    create_table :ecard_orders do |t|
      t.string :code
      t.integer :ecard_id
      t.boolean :sent
      
      t.timestamps
    end
    add_index :ecard_orders, [:ecard_id]
  end
end

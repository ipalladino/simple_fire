class AddEmailToEcardOrders < ActiveRecord::Migration
  def change
    add_column :ecard_orders, :email, :string
  end
end

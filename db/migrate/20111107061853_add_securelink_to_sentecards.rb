class AddSecurelinkToSentecards < ActiveRecord::Migration
  def self.up
    add_column :sent_ecards, :securelink, :string
  end

  def self.down
    remove_column :sent_ecards, :securelink
  end
end

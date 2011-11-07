class AddEmailUniquenessIndex < ActiveRecord::Migration
  def self.up
    add_index :senders, :email, :unique => true
  end

  def self.down
    remove_index :senders, :email
  end
end

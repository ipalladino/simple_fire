class AddSentToSentEcards < ActiveRecord::Migration
  def change
    add_column :sent_ecards, :sent, :boolean
  end
end

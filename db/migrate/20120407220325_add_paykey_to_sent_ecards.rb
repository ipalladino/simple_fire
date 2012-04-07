class AddPaykeyToSentEcards < ActiveRecord::Migration
  def change
    add_column :sent_ecards, :pay_key, :string
  end
end

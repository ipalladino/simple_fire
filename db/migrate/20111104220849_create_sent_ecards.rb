class CreateSentEcards < ActiveRecord::Migration
  def change
    create_table :sent_ecards do |t|
      t.string :recipientemail
      t.string :recipientname
      t.string :message1
      t.string :message2
      t.string :nametoshow
      t.string :senderemail
      t.integer :ecard_id

      t.timestamps
    end
    add_index :sent_ecards, [:ecard_id]
  end
end

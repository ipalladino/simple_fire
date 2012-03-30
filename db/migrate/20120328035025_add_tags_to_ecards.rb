class AddTagsToEcards < ActiveRecord::Migration
  def change
    add_column :ecards, :tags, :string
  end
end

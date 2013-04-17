class CreatePostType < ActiveRecord::Migration
  def self.up
   create_table :post_types do |t|
     t.text :name
     t.string :description
     t.timestamps
   end
  end

  def self.down
    drop_table :post_types
  end
end

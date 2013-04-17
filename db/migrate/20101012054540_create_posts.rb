class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :user_id
      t.integer :post_type_id
      t.text :title
      t.text :body_text
      t.binary :image
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end

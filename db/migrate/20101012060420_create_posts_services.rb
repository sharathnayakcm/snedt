class CreatePostsServices < ActiveRecord::Migration
  def self.up
     create_table :posts_services, :id=> false do |t|
       t.integer :post_id
       t.integer :service_id
     end
  end

  def self.down
    drop_table :posts_services
  end
end

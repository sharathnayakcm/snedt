class CreateStreamDetails < ActiveRecord::Migration
  def self.up
    create_table :stream_details do |t|
      t.string :streamable_type
      t.integer :streamable_id
      t.string :name
      t.integer :followers_count
      t.integer :favourites_count
      t.string :location
      t.text :description
      t.integer :friends_count
      t.string :utc_offset
      t.string :time_zone
      t.integer :statuses_count
      t.integer :sender_id
      t.integer :receiver_id
      t.string :profile_image_url
      t.date :created_date
      t.timestamps
    end
  end

  def self.down
    drop_table :stream_details
  end
end

class CreateFavouriteStreams < ActiveRecord::Migration
  def self.up
    create_table :favourite_streams do |t|
      t.integer :user_id
      t.integer :stream_id
      t.timestamps
    end
  end

  def self.down
    drop_table :favourite_streams
  end
end

class AddTumblrDetailsToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :tumblr_feed_type, :string
    add_column :streams, :tumblr_data_one, :text
    add_column :streams, :tumblr_data_two, :text
  end

  def self.down
    remove_column :streams, :tumblr_feed_type
    remove_column :streams, :tumblr_data_one
    remove_column :streams, :tumblr_data_two
  end
end

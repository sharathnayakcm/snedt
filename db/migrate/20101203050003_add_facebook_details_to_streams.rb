class AddFacebookDetailsToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :facebook_link_url, :string
    add_column :streams, :facebook_feed_type, :text
    add_column :streams, :facebook_feed_description, :text
  end

  def self.down
    remove_column :streams, :facebook_link_url
    remove_column :streams, :facebook_feed_type
    remove_column :streams, :facebook_feed_description
  end
end

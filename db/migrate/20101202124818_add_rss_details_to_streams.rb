class AddRssDetailsToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :rss_link_id, :integer
    add_column :streams, :rss_feed_description, :text
  end

  def self.down
    remove_column :streams, :rss_link_id
    remove_column :streams, :rss_feed_description
  end
end

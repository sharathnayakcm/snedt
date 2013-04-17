class AddRssOriginalSiteContentToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :rss_original_site_content, :text
  end

  def self.down
    remove_column :streams, :rss_original_site_content
  end
end

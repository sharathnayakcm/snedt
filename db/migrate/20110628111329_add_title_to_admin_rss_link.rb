class AddTitleToAdminRssLink < ActiveRecord::Migration
  def self.up
    add_column :admin_rss_links, :title, :string
  end

  def self.down
    remove_column :admin_rss_links, :title
  end
end

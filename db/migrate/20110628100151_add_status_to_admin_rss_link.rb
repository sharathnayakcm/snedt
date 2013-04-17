class AddStatusToAdminRssLink < ActiveRecord::Migration
  def self.up
    add_column :admin_rss_links, :status, :boolean
  end

  def self.down
    remove_column :admin_rss_links, :status
  end
end

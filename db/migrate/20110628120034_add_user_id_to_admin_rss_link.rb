class AddUserIdToAdminRssLink < ActiveRecord::Migration
  def self.up
    add_column :admin_rss_links, :user_id, :integer
  end

  def self.down
    remove_column :admin_rss_links, :user_id
  end
end

class ChangeColumnLinkToUrl < ActiveRecord::Migration
  def self.up
    rename_column :admin_rss_links, :link, :url
  end

  def self.down
  end
end

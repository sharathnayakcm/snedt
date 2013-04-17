class CreateAdminRssLinks < ActiveRecord::Migration
  def self.up
    create_table :admin_rss_links do |t|
      t.string :link
      t.timestamps
    end
  end

  def self.down
    drop_table :admin_rss_links
  end
end

class CreateRssLinks < ActiveRecord::Migration
  def self.up
    create_table :rss_links do |t|
      t.integer :user_id
      t.text :title
      t.text :url
      t.timestamps
    end
  end

  def self.down
    drop_table :rss_links
  end
end

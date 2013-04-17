class CreateStaticSiteContents < ActiveRecord::Migration
  def self.up
    create_table :static_site_contents do |t|
      t.string  "title"
      t.text    "text_content"
      t.string  "video_url"
      t.timestamps
    end
  end

  def self.down
    drop_table :static_site_contents
  end
end

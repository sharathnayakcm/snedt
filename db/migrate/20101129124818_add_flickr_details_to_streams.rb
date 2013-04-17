class AddFlickrDetailsToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :flickr_image_url, :string
    add_column :streams, :flickr_photo_title, :text
  end

  def self.down
    remove_column :streams, :flickr_image_url
    remove_column :streams, :flickr_photo_title
  end
end

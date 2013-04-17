class AddVideoUrlToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :video_url, :string
  end

  def self.down
    remove_column :streams, :video_url
  end
end

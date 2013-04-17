class AddVideoToAsset < ActiveRecord::Migration
  def self.up
    add_column :assets, :video_file_name, :string
    add_column :assets, :video_content_type, :string
    add_column :assets, :video_file_size, :string
    add_column :assets, :state, :string
  end

  def self.down
    remove_column :assets, :video_file_name
    remove_column :assets, :video_content_type
    remove_column :assets, :video_file_size
    remove_column :assets, :state
  end
end

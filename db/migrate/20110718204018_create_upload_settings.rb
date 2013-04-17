class CreateUploadSettings < ActiveRecord::Migration
  def self.up
    create_table :upload_settings do |t|
      t.integer :video_size
      t.integer :photo_size
      t.timestamps
    end
  end

  def self.down
    drop_table :upload_settings
  end
end

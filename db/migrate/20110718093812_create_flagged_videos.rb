class CreateFlaggedVideos < ActiveRecord::Migration
  def self.up
    create_table :flagged_videos do |t|
      t.integer :stream_id
      t.integer :reporter_id
      t.string  :description
      t.timestamps
    end
  end

  def self.down
    drop_table :flagged_videos
  end
end

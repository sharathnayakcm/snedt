class AddProcessedToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :video_status_id, :integer
    add_column :streams, :membership_id, :integer
  end

  def self.down
    remove_column :streams, :video_status_id
    remove_column :streams, :membership_id
  end
end

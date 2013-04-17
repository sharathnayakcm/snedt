class AddDefaultStreamCreatedDate < ActiveRecord::Migration
  def self.up
    change_column :streams, :stream_created_at, :timestamp, :default => Time.now
  end

  def self.down
    change_column :streams, :stream_created_at, :timestamp
  end
end

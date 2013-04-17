class AddStreamCreatedAt < ActiveRecord::Migration
  def self.up
    add_column :streams, :post_type, :integer
    add_column :streams, :stream_created_at, :timestamp
  end

  def self.down
    remove_column :streams, :post_type
    remove_column :streams, :stream_created_at
  end
end

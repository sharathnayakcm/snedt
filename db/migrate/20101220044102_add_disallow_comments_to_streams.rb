class AddDisallowCommentsToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :disallow_comments, :boolean, :default => false
  end

  def self.down
    remove_column :streams, :disallow_comments
  end
end

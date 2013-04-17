class AddStatusColumnsToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :is_displayed, :boolean, :default => false
    add_column :streams, :is_read, :boolean, :default => false
  end

  def self.down
    remove_column :streams, :is_displayed
    remove_column :streams, :is_read
  end
end
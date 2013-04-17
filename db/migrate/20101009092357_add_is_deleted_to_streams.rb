class AddIsDeletedToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :is_deleted, :boolean
  end

  def self.down
    remove_column :streams, :is_deleted
  end
end

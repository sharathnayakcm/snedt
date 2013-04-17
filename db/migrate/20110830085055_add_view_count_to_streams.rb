class AddViewCountToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :view_count, :integer, :default => 0
  end

  def self.down
    remove_column :streams, :view_count, :integer, :default => 0
  end
end

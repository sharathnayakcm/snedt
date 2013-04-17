class AddTagToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :tag, :string
  end

  def self.down
    remove_column :stream, :tag
  end
end

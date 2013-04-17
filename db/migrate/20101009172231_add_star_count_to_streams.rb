class AddStarCountToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :star_count, :integer
  end

  def self.down
    remove_column :streams, :star_count
  end
end

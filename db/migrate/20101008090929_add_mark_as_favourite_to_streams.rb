class AddMarkAsFavouriteToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :is_favourite, :boolean
  end

  def self.down
    remove_column :streams, :is_favourite   
  end
end

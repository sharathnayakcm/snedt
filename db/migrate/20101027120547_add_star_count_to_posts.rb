class AddStarCountToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :star_count, :integer, :default => "0"
  end

  def self.down
    remove_column :posts, :star_count
  end
end

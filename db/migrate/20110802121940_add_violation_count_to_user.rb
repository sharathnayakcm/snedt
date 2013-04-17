class AddViolationCountToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :violation_count, :integer, :default => 0
  end

  def self.down
    remove_column :users, :violation_count
  end
end

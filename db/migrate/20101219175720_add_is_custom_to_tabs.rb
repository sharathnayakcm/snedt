class AddIsCustomToTabs < ActiveRecord::Migration
  def self.up
    add_column :tabs, :is_custom, :boolean, :default => false
  end

  def self.down
    remove_column :tabs, :description
  end
end

class ChangeActiveStatusInUsers < ActiveRecord::Migration
  def self.up
    change_column :users,:active,:boolean,:default => false
  end

  def self.down
    change_column :users,:active,:boolean,:default => true
  end
end

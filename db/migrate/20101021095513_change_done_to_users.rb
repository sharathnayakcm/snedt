class ChangeDoneToUsers < ActiveRecord::Migration
  def self.up
     change_column :users,:done,:boolean, :default => false
  end

  def self.down
     change_column :users,:done,:boolean
  end
end

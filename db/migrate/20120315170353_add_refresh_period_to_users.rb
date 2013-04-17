class AddRefreshPeriodToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :refresh_period, :integer, :default => 120
  end

  def self.down
    remove_column :users, :refresh_period
  end
end

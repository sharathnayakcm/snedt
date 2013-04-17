class AddCycleStartDateAndUploadedSizeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :uploaded_size, :integer, :defualt => 0
    add_column :users, :cycle_start_date, :datetime, :default => Time.now
    add_column :assets, :user_id, :integer
  end

  def self.down
    remove_column :users, :uploaded_size
    remove_column :users, :cycle_start_date
    remove_column :assets, :user_id
  end
end

class AddWhoSeeFullNameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :who_see_full_name, :string, :deafult => 1
  end

  def self.down
    remove_column :users, :who_see_full_name
  end
end

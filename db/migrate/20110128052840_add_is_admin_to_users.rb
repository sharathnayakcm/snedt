class AddIsAdminToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_admin, :boolean , :defaut => false
  end

  def self.down
    remove_column :users, :is_admin, :boolean
  end
end
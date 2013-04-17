class AddColumnsToUserServices < ActiveRecord::Migration
  def self.up
    add_column :user_services, :token, :string
    add_column :user_services, :secret, :string
  end

  def self.down
    remove_column :user_services, :token
    remove_column :user_services, :secret
  end
end

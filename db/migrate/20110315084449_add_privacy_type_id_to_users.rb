class AddPrivacyTypeIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :privacy_type_id, :integer
  end

  def self.down
    remove_column :users, :privacy_type_id
  end
end

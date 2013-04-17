class AddPrivacyTypeIdToUserServices < ActiveRecord::Migration
  def self.up
    add_column :user_services, :privacy_type_id, :integer
  end

  def self.down
    remove_column :user_services, :privacy_type_id
  end
end

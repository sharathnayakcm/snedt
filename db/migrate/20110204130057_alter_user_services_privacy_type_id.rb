class AlterUserServicesPrivacyTypeId < ActiveRecord::Migration
  def self.up
    change_column :user_services, :privacy_type_id, :string
  end

  def self.down
  end
end

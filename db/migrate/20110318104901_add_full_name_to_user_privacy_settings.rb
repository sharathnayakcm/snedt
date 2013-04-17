class AddFullNameToUserPrivacySettings < ActiveRecord::Migration
  def self.up
    add_column :user_privacy_settings, :full_name, :string
  end

  def self.down
    remove_column :user_privacy_settings, :full_name
  end
end
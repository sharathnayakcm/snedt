class AddPrivacyToCompanyAndUser < ActiveRecord::Migration
  def self.up
    add_column :user_privacy_settings, :is_searchable, :boolean, :default => false
    add_column :brand_privacies, :is_searchable, :boolean, :default => false
    add_column :company_privacies, :is_searchable, :boolean, :default => false
  end

  def self.down
    remove_column :user_privacy_settings, :is_searchable
    remove_column :brand_privacies, :is_searchable
    remove_column :company_privacies, :is_searchable
  end
end

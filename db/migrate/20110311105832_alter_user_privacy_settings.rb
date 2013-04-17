class AlterUserPrivacySettings < ActiveRecord::Migration
  def self.up
    change_column :user_privacy_settings, :rss, :string
    change_column :user_privacy_settings, :profile, :string
    change_column :user_privacy_settings, :stream, :string
  end

  def self.down
  end
end

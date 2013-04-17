class CreateUserPrivacySettings < ActiveRecord::Migration
  def self.up
    create_table :user_privacy_settings do |t|
      t.integer :profile
      t.integer :rss
      t.integer :stream
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :user_privacy_settings
  end
end

class PrivacyTypes < ActiveRecord::Migration
  def self.up
     create_table :privacy_types do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :privacy_types
  end
end

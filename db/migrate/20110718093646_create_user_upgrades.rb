class CreateUserUpgrades < ActiveRecord::Migration
  def self.up
    add_column :users, :free_user_since, :datetime, :default => Time.now
    create_table :user_upgrades do |t|
      t.integer :user_id
      t.integer :days_before_upgrade
      t.timestamps
    end
  end

  def self.down
    drop_table :user_upgrades
  end
end

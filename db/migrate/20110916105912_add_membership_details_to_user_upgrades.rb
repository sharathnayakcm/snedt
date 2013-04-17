class AddMembershipDetailsToUserUpgrades < ActiveRecord::Migration
  def self.up
    add_column :user_upgrades, :company_id, :integer
    add_column :user_upgrades, :from_membership_id, :integer
    add_column :user_upgrades, :to_membership_id, :integer
    add_column :user_upgrades, :from_to, :string
  end

  def self.down
    remove_column :user_upgrades, :company_id
    remove_column :user_upgrades, :from_membership_id
    remove_column :user_upgrades, :to_membership_id
    remove_column :user_upgrades, :from_to
  end
end

class AddCountFieldsToMembership < ActiveRecord::Migration
  def self.up
    add_column :memberships, :user_count, :integer
    add_column :memberships, :brand_count, :integer
  end

  def self.down
    remove_column :memberships, :user_count
    remove_column :memberships, :brand_count
  end
end

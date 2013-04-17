class AddSkinCountToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :skin_count, :integer
  end

  def self.down
    remove_column :memberships, :skin_count
  end
end

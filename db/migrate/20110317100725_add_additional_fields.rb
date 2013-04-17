class AddAdditionalFields < ActiveRecord::Migration
  def self.up
    add_column :services, :notes, :text
    add_column :spammed_users, :revealed_at, :datetime
  end

  def self.down
    remove_column :services, :notes
    remove_column :spammed_users, :revealed_at
  end
end

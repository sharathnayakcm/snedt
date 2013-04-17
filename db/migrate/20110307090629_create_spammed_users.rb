class CreateSpammedUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_spammer, :boolean, :default => false
    create_table :spammed_users do |t|
      t.integer :user_id
      t.integer :spammed_by_id
      t.boolean :is_spammer
      t.timestamps
    end
  end

  def self.down
    remove_column :users, :is_spammer
    drop_table :spammed_users
  end
end

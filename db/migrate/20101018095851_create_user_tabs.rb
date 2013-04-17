class CreateUserTabs < ActiveRecord::Migration
  def self.up
    create_table :user_tabs do |t|
      t.integer :user_id
      t.integer :tab_id
      t.timestamps
    end
  end

  def self.down
    drop_table :user_tabs
  end
end

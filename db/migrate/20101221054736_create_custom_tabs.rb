class CreateCustomTabs < ActiveRecord::Migration
  def self.up
    create_table :custom_tabs do |t|
      t.string  :name
      t.integer :user_id
      t.string  :service_ids
      t.string  :user_type_ids
      t.integer :filter_user_id
    end
  end

  def self.down
    drop_table :custom_tabs
  end
end
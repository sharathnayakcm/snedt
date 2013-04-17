class CreateTabs < ActiveRecord::Migration
  def self.up
    create_table :tabs do |t|
      t.string :name
      t.string :description
      t.string :tab_path
      t.timestamps
    end
  end

  def self.down
    drop_table :tabs
  end
end

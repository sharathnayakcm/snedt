class CreateSkins < ActiveRecord::Migration
  def self.up
    create_table :skins do |t|
      t.integer :user_id
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :skins
  end
end

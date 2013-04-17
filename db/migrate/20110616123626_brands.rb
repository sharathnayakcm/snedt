class Brands < ActiveRecord::Migration
  def self.up
    create_table :brands do |t|
      t.string  :name
      t.integer :company_id
      t.string  :url
      t.string  :description
      t.boolean :is_default
      t.boolean :active
      t.timestamps
    end
  end

  def self.down
    drop_table :brands
  end
end

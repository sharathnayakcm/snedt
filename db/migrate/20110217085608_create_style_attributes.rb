class CreateStyleAttributes < ActiveRecord::Migration
  def self.up
    create_table :style_attributes do |t|
      t.string :name
      t.string :category
      t.timestamps
    end
  end

  def self.down
    drop_table :style_attributes
  end
end

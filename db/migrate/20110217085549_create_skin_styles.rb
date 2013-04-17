class CreateSkinStyles < ActiveRecord::Migration
  def self.up
    create_table :skin_styles do |t|
      t.integer :skin_id
      t.integer :panel_type_id
      t.integer :style_attribute_id
      t.string  :attribute_value
      t.timestamps
    end
  end

  def self.down
    drop_table :skin_styles
  end
end

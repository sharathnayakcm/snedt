class AddDisplayNameToStyleAttributes < ActiveRecord::Migration
  def self.up
    add_column :style_attributes, :display_name, :string
  end

  def self.down
    remove_column :style_attributes, :display_name
  end
end

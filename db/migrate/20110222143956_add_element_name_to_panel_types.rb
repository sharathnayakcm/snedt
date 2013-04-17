class AddElementNameToPanelTypes < ActiveRecord::Migration
  def self.up
    add_column :panel_types, :element_name, :string
  end

  def self.down
    remove_column :panel_types, :element_name
  end
end

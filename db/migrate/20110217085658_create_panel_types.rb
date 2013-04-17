class CreatePanelTypes < ActiveRecord::Migration
  def self.up
    create_table :panel_types do |t|
      t.string  :name
      t.timestamps
    end
  end

  def self.down
    drop_table :panel_types
  end
end

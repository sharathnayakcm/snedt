class CreatePreferenceTypes < ActiveRecord::Migration
  def self.up
    create_table :preference_types do |t|
      t.string  "name"
      t.text    "description"
      t.timestamps
    end
  end

  def self.down
    drop_table :preference_types
  end
end

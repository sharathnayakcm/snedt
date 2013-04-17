class CreatePreferences < ActiveRecord::Migration
  def self.up
    create_table :preferences do |t|
      t.integer "user_id"
      t.integer "preference_id"
      t.timestamps
    end
  end

  def self.down
    drop_table :preferences
  end
end

class CreatePoints < ActiveRecord::Migration
  def self.up
    create_table :points do |t|
      t.string :activity_types
      t.integer :activity_points

      t.timestamps
    end
  end

  def self.down
    drop_table :points
  end
end

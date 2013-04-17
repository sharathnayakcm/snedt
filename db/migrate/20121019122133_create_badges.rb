class CreateBadges < ActiveRecord::Migration
  def self.up
    create_table :badges do |t|
      t.string :name
      t.integer :level
      t.integer :points_required
      t.string :badge_type

      t.timestamps
    end
  end

  def self.down
    drop_table :badges
  end
end

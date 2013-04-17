class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.integer :user_id
      t.references :actionable, :polymorphic => true
      t.integer :activity_type
      t.integer :action_user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end

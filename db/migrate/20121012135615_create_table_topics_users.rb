class CreateTableTopicsUsers < ActiveRecord::Migration
  def self.up
    create_table :topics_users, :id => false do |t|
      t.references :topic
      t.references :user
    end
    add_index :topics_users, [:topic_id, :user_id]
    add_index :topics_users, [:user_id, :topic_id]
  end

  def self.down
    drop_table :topics_users
  end
end

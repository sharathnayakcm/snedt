class AddReasonToAbuseContent < ActiveRecord::Migration
  def self.up
    add_column :abuse_contents, :reason, :string
    add_column :abuse_contents, :user_id, :integer
  end

  def self.down
    remove_column :abuse_contents, :reason
    remove_column :abuse_contents, :user_id
  end
end

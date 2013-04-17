class ChangeStreamDetailsCreatedDate < ActiveRecord::Migration
  def self.up
    change_column :stream_details, :created_date, :datetime
  end

  def self.down
    change_column :stream_details, :created_date, :date
  end
end

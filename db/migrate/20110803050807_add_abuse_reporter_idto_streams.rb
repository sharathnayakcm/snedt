class AddAbuseReporterIdtoStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :abuse_reporter_id , :integer
  end

  def self.down
    remove_column :streams, :abuse_reporter_id
  end
end

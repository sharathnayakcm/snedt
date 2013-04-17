class ChangeReportAbuseColumnType < ActiveRecord::Migration
  def self.up
    change_column(:streams, :report_abuse, :integer)
  end

  def self.down
  end
end

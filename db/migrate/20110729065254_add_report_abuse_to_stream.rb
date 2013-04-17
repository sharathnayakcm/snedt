class AddReportAbuseToStream < ActiveRecord::Migration
  def self.up
    add_column :streams, :report_abuse, :boolean
  end

  def self.down
    remove_column :streams, :report_abuse
  end
end

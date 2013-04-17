class AddStreamPostedDateToCustomStreamFilters < ActiveRecord::Migration
  def self.up
    add_column :custom_stream_filters, :stream_posted_date, :timestamp
  end

  def self.down
    remove_column :custom_stream_filters, :stream_posted_date
  end
end

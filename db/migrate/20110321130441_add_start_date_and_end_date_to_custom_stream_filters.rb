class AddStartDateAndEndDateToCustomStreamFilters < ActiveRecord::Migration
  def self.up
    add_column :custom_stream_filters, :stream_start_date, :timestamp
    add_column :custom_stream_filters, :stream_end_date, :timestamp
  end

  def self.down
    remove_column :custom_stream_filters, :stream_start_date
    remove_column :custom_stream_filters, :stream_end_date
  end
end

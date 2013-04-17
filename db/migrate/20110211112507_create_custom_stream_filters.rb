class CreateCustomStreamFilters < ActiveRecord::Migration
  def self.up
    create_table :custom_stream_filters do |t|
      t.integer "user_id"
      t.string "name"
      t.integer "post_type_id"
      t.string "user_service_ids"
      t.text "stream_tags"
      t.timestamps
    end
  end

  def self.down
    drop_table :custom_stream_filters
  end
end

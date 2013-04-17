class CreateBrandServices < ActiveRecord::Migration
  def self.up
    create_table :brand_services do |t|
    t.integer  "service_id"
    t.integer  "brand_id"
    t.integer  "company_id"
    t.string   "profile_name"
    t.string   "user_name"
    t.string   "password"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "secret"
    t.boolean  "share_status_update"
    t.boolean  "share_favourites"
    t.boolean  "share_content"
    t.string   "privacy_type_id"
    t.boolean  "disallow_comments",         :default => false
    t.string   "service_configuration_ids"

    end
  end

  def self.down
  end
end

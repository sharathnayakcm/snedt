# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121204054219) do

  create_table "abuse_comments", :force => true do |t|
    t.integer  "stream_id"
    t.string   "user_comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "abuse_contents", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stream_id"
    t.string   "user_comments"
    t.string   "reason"
    t.integer  "user_id"
  end

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "actionable_id"
    t.string   "actionable_type"
    t.integer  "activity_type"
    t.integer  "action_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "topic_id"
  end

  create_table "admin_rss_links", :force => true do |t|
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "status"
    t.string   "title"
    t.integer  "user_id"
  end

  create_table "assets", :force => true do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.string   "asset_file_name"
    t.string   "asset_content_type"
    t.integer  "asset_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "company_id"
    t.string   "video_file_name"
    t.string   "video_content_type"
    t.string   "video_file_size"
    t.string   "state"
    t.integer  "brand_id"
  end

  create_table "badges", :force => true do |t|
    t.string   "name"
    t.integer  "level"
    t.integer  "points_required"
    t.string   "badge_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bdrb_job_queues", :force => true do |t|
    t.text     "args"
    t.string   "worker_name"
    t.string   "worker_method"
    t.string   "job_key"
    t.integer  "taken"
    t.integer  "finished"
    t.integer  "timeout"
    t.integer  "priority"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.string   "tag"
    t.string   "submitter_info"
    t.string   "runner_info"
    t.string   "worker_key"
    t.datetime "scheduled_at"
  end

  create_table "blocked_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "blocked_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brand_privacies", :force => true do |t|
    t.integer  "brand_id"
    t.integer  "company_id"
    t.integer  "visible_to"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "profile"
    t.integer  "rss"
    t.integer  "stream"
    t.boolean  "is_searchable", :default => false
  end

  create_table "brand_services", :force => true do |t|
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
    t.integer  "user_id"
    t.string   "fb_page_id"
    t.string   "fb_page_name"
  end

  create_table "brand_user_groups", :force => true do |t|
    t.integer  "user_id"
    t.integer  "company_id"
    t.integer  "brand_id"
    t.integer  "access_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "status",      :default => true
  end

  create_table "brands", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.string   "url"
    t.string   "description"
    t.boolean  "is_default"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.string   "brand_url"
    t.integer  "active_skin_id"
  end

  create_table "comments", :force => true do |t|
    t.integer  "stream_id"
    t.integer  "user_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fb_comment_id"
    t.string   "twitter_reply_id"
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "description"
    t.string   "country"
    t.integer  "membership_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "uploaded_size",     :default => 0
    t.datetime "deleted_at"
    t.datetime "next_payment_date"
    t.datetime "cycle_start_date"
  end

  create_table "company_followers", :force => true do |t|
    t.integer  "company_id"
    t.integer  "brand_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "company_invitations", :force => true do |t|
    t.integer  "company_id"
    t.integer  "brand_id"
    t.integer  "access_type"
    t.string   "invitee_email_address"
    t.boolean  "is_assigned",           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "company_invites", :force => true do |t|
    t.integer  "brand_id"
    t.string   "email_id"
    t.integer  "role_id"
    t.boolean  "deactivated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "company_privacies", :force => true do |t|
    t.integer  "company_id"
    t.integer  "visible_to"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_searchable", :default => false
  end

  create_table "company_user_groups", :force => true do |t|
    t.integer  "user_id"
    t.integer  "access_type"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "custom_stream_filters", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "post_type_id"
    t.string   "user_service_ids"
    t.text     "stream_tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "stream_posted_date"
    t.datetime "stream_start_date"
    t.datetime "stream_end_date"
  end

  create_table "custom_tabs", :force => true do |t|
    t.string  "name"
    t.integer "user_id"
    t.string  "service_ids"
    t.string  "user_type_ids"
    t.string  "user_service_ids"
    t.string  "filter_user_ids"
  end

  create_table "default_stream_actions", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "allow_comments",  :default => true
    t.boolean  "review",          :default => true
    t.boolean  "retweet",         :default => true
    t.boolean  "favourite",       :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "brand_id"
    t.integer  "user_service_id"
  end

  create_table "downgrades", :force => true do |t|
    t.integer  "user_id"
    t.datetime "next_payment_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favourite_streams", :force => true do |t|
    t.integer  "user_id"
    t.integer  "stream_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flagged_videos", :force => true do |t|
    t.integer  "stream_id"
    t.integer  "reporter_id"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "followers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "follower_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_blocked",  :default => false
  end

  create_table "friends", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "amount"
    t.string   "membership_type"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "upload_limit"
    t.integer  "user_count"
    t.integer  "brand_count"
    t.integer  "skin_count"
    t.boolean  "is_trial_period_allowed", :default => false
    t.integer  "trial_period"
  end

  create_table "notifications", :force => true do |t|
    t.string   "name"
    t.string   "subject"
    t.string   "cc"
    t.string   "bcc"
    t.text     "content"
    t.boolean  "is_displayable"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.boolean  "active",          :default => true
    t.string   "subject_arabic"
    t.text     "content_arabic"
    t.string   "name_arabic"
    t.boolean  "is_notification", :default => true
    t.integer  "delivery_day"
  end

  create_table "notifications_users", :id => false, :force => true do |t|
    t.integer "notification_id"
    t.integer "user_id"
  end

  create_table "panel_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "element_name"
  end

  create_table "payments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "amount"
    t.string   "vendor"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "membership_id"
    t.integer  "company_id"
  end

  create_table "points", :force => true do |t|
    t.string   "activity_types"
    t.integer  "activity_points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "post_service_groups", :force => true do |t|
    t.string  "name"
    t.integer "post_type_id"
    t.integer "user_id"
    t.string  "user_service_ids"
    t.integer "brand_id"
  end

  create_table "post_types", :force => true do |t|
    t.text     "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "post_type_id"
    t.text     "title"
    t.text     "body_text"
    t.binary   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "star_count",   :default => 0
  end

  create_table "posts_services", :id => false, :force => true do |t|
    t.integer "post_id"
    t.integer "service_id"
  end

  create_table "preference_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "preferences", :force => true do |t|
    t.integer  "user_id"
    t.integer  "preference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "privacy_groups", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "group_ids"
    t.string   "group_user_ids"
    t.string   "service_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_ids"
  end

  create_table "privacy_types", :force => true do |t|
    t.string "name"
  end

  create_table "referrals", :force => true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "code"
    t.time     "expiry_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rss_links", :force => true do |t|
    t.integer  "user_id"
    t.text     "title"
    t.text     "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "saved_searches", :force => true do |t|
    t.integer  "user_id"
    t.text     "search_for"
    t.text     "search_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_configurations", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "services", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "callback_url"
    t.integer  "service_category_id"
    t.text     "api_token"
    t.text     "api_key"
    t.boolean  "active"
    t.string   "service_configuration_ids"
    t.text     "notes"
    t.text     "notes_arabic"
  end

  create_table "site_configurations", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skin_styles", :force => true do |t|
    t.integer  "skin_id"
    t.integer  "panel_type_id"
    t.integer  "style_attribute_id"
    t.string   "attribute_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skins", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "brand_id"
  end

  create_table "spammed_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "spammed_by_id"
    t.boolean  "is_spammer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.datetime "revealed_at"
  end

  create_table "static_site_contents", :force => true do |t|
    t.string   "title"
    t.text     "text_content"
    t.string   "video_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stream_details", :force => true do |t|
    t.string   "streamable_type"
    t.string   "name"
    t.integer  "followers_count"
    t.integer  "favourites_count"
    t.string   "location"
    t.text     "description"
    t.integer  "friends_count"
    t.string   "utc_offset"
    t.string   "time_zone"
    t.integer  "statuses_count"
    t.string   "profile_image_url"
    t.datetime "created_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stream_id"
    t.string   "user_name"
  end

  create_table "stream_tags", :force => true do |t|
    t.integer  "stream_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stream_views", :force => true do |t|
    t.integer  "stream_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "streams", :force => true do |t|
    t.integer  "service_id"
    t.integer  "user_id"
    t.string   "stream_id"
    t.integer  "message_type_id"
    t.text     "text"
    t.boolean  "is_sender_following"
    t.boolean  "is_receiver_following"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.boolean  "is_displayed",              :default => false
    t.boolean  "is_read",                   :default => false
    t.boolean  "is_favourite"
    t.boolean  "is_deleted"
    t.integer  "star_count"
    t.string   "tag"
    t.integer  "user_service_id"
    t.integer  "post_type"
    t.datetime "stream_created_at",         :default => '2011-05-03 13:41:18'
    t.string   "flickr_image_url"
    t.text     "flickr_photo_title"
    t.integer  "rss_link_id"
    t.text     "rss_feed_description"
    t.string   "facebook_link_url"
    t.text     "facebook_feed_type"
    t.text     "facebook_feed_description"
    t.string   "description"
    t.boolean  "disallow_comments",         :default => false
    t.string   "send_to"
    t.string   "tumblr_feed_type"
    t.text     "tumblr_data_one"
    t.text     "tumblr_data_two"
    t.string   "video_url"
    t.text     "rss_original_site_content"
    t.boolean  "disallow_retweet",          :default => false
    t.boolean  "retweeted",                 :default => false
    t.integer  "brand_service_id"
    t.integer  "brand_id"
    t.integer  "company_id"
    t.integer  "report_abuse"
    t.integer  "abuse_reporter_id"
    t.integer  "view_count",                :default => 0
    t.integer  "video_status_id"
    t.integer  "membership_id"
    t.integer  "topic_id"
  end

  create_table "style_attributes", :force => true do |t|
    t.string   "name"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_name"
  end

  create_table "tabs", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "tab_path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_custom",   :default => false
  end

  create_table "tags", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thank_yous", :force => true do |t|
    t.integer  "user_id"
    t.integer  "stream_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics_users", :id => false, :force => true do |t|
    t.integer "topic_id"
    t.integer "user_id"
  end

  add_index "topics_users", ["topic_id", "user_id"], :name => "index_topics_users_on_topic_id_and_user_id"
  add_index "topics_users", ["user_id", "topic_id"], :name => "index_topics_users_on_user_id_and_topic_id"

  create_table "twitter_accounts", :force => true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.string   "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "upload_settings", :force => true do |t|
    t.integer  "video_size"
    t.integer  "photo_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_details", :force => true do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "alternate_email"
    t.string   "phone_number"
    t.string   "mobile_number"
    t.string   "country"
    t.text     "about_me"
    t.text     "education"
    t.integer  "availability"
    t.string   "time_zone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_privacy_settings", :force => true do |t|
    t.string   "profile"
    t.string   "rss"
    t.string   "stream"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name"
    t.boolean  "is_searchable", :default => false
  end

  create_table "user_roles", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_services", :force => true do |t|
    t.integer  "service_id"
    t.integer  "user_id"
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
    t.string   "fb_page_id"
    t.string   "fb_page_name"
    t.string   "profile_image_url"
  end

  create_table "user_tabs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "tab_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_followers",  :default => false
    t.boolean  "is_followings", :default => false
    t.boolean  "is_friends",    :default => false
    t.boolean  "is_fb",         :default => false
    t.boolean  "is_twitter",    :default => false
    t.boolean  "is_flickr",     :default => false
    t.string   "user_name"
  end

  create_table "user_upgrades", :force => true do |t|
    t.integer  "user_id"
    t.integer  "days_before_upgrade"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "from_membership_id"
    t.integer  "to_membership_id"
    t.string   "from_to"
  end

  create_table "users", :force => true do |t|
    t.string   "user_name"
    t.string   "email",                                                  :null => false
    t.string   "crypted_password",                                       :null => false
    t.string   "password_salt",                                          :null => false
    t.string   "persistence_token",                                      :null => false
    t.string   "perishable_token",                                       :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "deleted_at"
    t.datetime "last_login"
    t.boolean  "active",              :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "done",                :default => false
    t.string   "status",              :default => "5"
    t.string   "time_zone"
    t.string   "full_name"
    t.string   "language"
    t.boolean  "friends_find",        :default => false
    t.boolean  "is_admin"
    t.boolean  "is_blocked",          :default => false
    t.integer  "blocked_user_id"
    t.integer  "active_skin_id"
    t.boolean  "is_spammer",          :default => false
    t.integer  "privacy_type_id"
    t.string   "country"
    t.string   "who_see_full_name"
    t.integer  "membership_id"
    t.datetime "next_payment_date"
    t.integer  "uploaded_size"
    t.datetime "cycle_start_date",    :default => '2011-09-08 07:34:11'
    t.datetime "free_user_since",     :default => '2011-09-08 07:34:13'
    t.integer  "violation_count",     :default => 0
    t.string   "prefered_language",   :default => "en"
    t.integer  "refresh_period",      :default => 120
  end

end

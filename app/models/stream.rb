class Stream < ActiveRecord::Base
  has_one :sender, :class_name => "StreamDetail", :conditions => "stream_details.streamable_type = 'Sender'"
  has_one :receiver, :class_name => "StreamDetail", :conditions => "stream_details.streamable_type = 'Receiver'"
  belongs_to :user
  has_many :comments , :order => "comments.created_at DESC"
  has_many :stream_views , :order => "stream_views.created_at DESC"
  has_many :stream_tags
  belongs_to :service
  belongs_to :topic
  belongs_to :user_service
  belongs_to :rss_link
  has_many :assets, :as => :attachable
  has_many :tags, :through => :stream_tags
  has_one :abuse_content
  has_many :favourite_streams
  has_one :stream_detail
  has_many :thank_yous

  #Brand related associations
  belongs_to :brand_service
  belongs_to :brand
  belongs_to :company

  #NAMED SCOPES
  named_scope :not_displayed, :conditions => "(is_displayed = false or is_displayed is null) and brand_id is null and message_type_id != 8", :order => "stream_created_at ASC"
  named_scope :not_displayed_for_brands, :conditions => "(is_displayed = false or is_displayed is null) and brand_id is not null and message_type_id != 8", :order => "stream_created_at ASC"
  named_scope :displayed, :conditions => "(is_displayed = true and is_deleted is null) and brand_id is null and message_type_id != 8", :order => "stream_created_at DESC"
  named_scope :displayed_for_brand, :conditions => "(is_displayed = true and is_deleted is null and brand_id is not null) and message_type_id != 8", :order => "stream_created_at DESC"
  named_scope :not_displayed_rss, :conditions => "is_displayed = false or is_displayed is null", :order => "stream_created_at ASC"
  named_scope :displayed_rss, :conditions => "is_displayed = true and is_deleted is null", :order => "stream_created_at DESC"
  named_scope :unread_items, :conditions => "(is_read = false and is_deleted is null) and message_type_id != 8" , :order => "stream_created_at DESC"
  named_scope :read_items, :conditions => "(is_read = true and is_deleted is null) and message_type_id != 8" , :order => "stream_created_at DESC"
  named_scope :read_items_rss, :conditions => "is_read = true and is_deleted is null"
  named_scope :unread_items_rss, :conditions => "is_read = false and is_deleted is null"
  named_scope :followings, :conditions => "sender_id = '43826092' or receiver_id = '43826092'"
  named_scope :edintity_streams, :conditions => "(stream_id is null or (topic_id is not null and stream_id is not null))and message_type_id != 8 and brand_id is null and is_deleted is null" , :order => "stream_created_at DESC"
  named_scope :from_services, :conditions => "(stream_id is not null) and message_type_id != 8 and brand_id is null and is_deleted is null" , :order => "stream_created_at DESC"
  named_scope :edintity_brand_streams, :conditions => "(stream_id is null) and message_type_id != 8 and brand_id is not null and is_deleted is null" , :order => "stream_created_at DESC"
  #TODO Code to be reviewed
  named_scope :edintity_photo_streams, :conditions => "stream_id is null  and post_type = 7 and brand_id is null and is_deleted is null", :order => "stream_created_at DESC"
  named_scope :edintity_status_streams, :conditions => "stream_id is null  and post_type = 1 and brand_id is null and is_deleted is null", :order => "stream_created_at DESC"
  named_scope :edintity_blog_streams, :conditions => "stream_id is null  and post_type = 9 and brand_id is null and is_deleted is null", :order => "stream_created_at DESC"
  named_scope :edintity_link_streams, :conditions => "stream_id is null  and post_type = 3 and brand_id is null and is_deleted is null" , :order => "stream_created_at DESC"
  named_scope :edintity_video_streams, :conditions => "stream_id is null  and post_type = 1 and brand_id is null and is_deleted is null", :order => "stream_created_at DESC"
  #company stream name scope
  named_scope :company_edintity_streams, :conditions => "(is_deleted = 0 OR is_deleted is NULL)  AND (stream_id is null) and message_type_id != 8 " , :order => "stream_created_at DESC"
  named_scope :company_edintity_photo_streams, :conditions => "(is_deleted = 0 OR is_deleted is NULL)  AND stream_id is null  and post_type = 7 ", :order => "stream_created_at DESC"
  named_scope :company_edintity_status_streams, :conditions => "(is_deleted = 0 OR is_deleted is NULL)  AND stream_id is null  and post_type = 1 ", :order => "stream_created_at DESC"
  named_scope :company_edintity_blog_streams, :conditions => "(is_deleted = 0 OR is_deleted is NULL)  AND stream_id is null  and post_type = 9 ", :order => "stream_created_at DESC"
  named_scope :company_edintity_link_streams, :conditions => "(is_deleted = 0 OR is_deleted is NULL)  AND stream_id is null  and post_type = 3 ", :order => "stream_created_at DESC"
  named_scope :company_edintity_video_streams, :conditions => "(is_deleted = 0 OR is_deleted is NULL)  AND stream_id is null  and post_type = 1 ", :order => "stream_created_at DESC"

  #VALIDATIONS
  validates_presence_of :topic_id

  after_create :update_membership

  PROFILE_STATUS={
    1 => "tweeted",
    2 => "on Facebook",
    3 => "on YouTube",
    4 => "on Vimeo",
    5 => "bookmarked in Delicious",
    6 => "bookmarked in StumbleUpon",
    7 => "on Flickr",
    9 => "on Tumblr",
    0 => "on edintity"
  }

  VIDEO_STATUS={
    "processing" => 1,
    "success" => 2,
    "error" => 3
  }

  def self.edintity_and_topic_streams(current_user, topic_id=nil,tag_name=nil)
    if topic_id.present?
      self.find_all_by_topic_id(topic_id)
    elsif tag_name.present?
      tag = Tag.find_by_name(tag_name)
      return tag.streams
    else
   topic_ids = current_user.topics.map(&:id)
      self.find(:all, :conditions => ["((stream_id is null and user_id = ?) or (topic_id is not null and stream_id is not null and user_id = ?) or topic_id in (?))and message_type_id != 8 and brand_id is null and is_deleted is null", current_user.id, current_user.id, topic_ids ], :order => "stream_created_at DESC")
    end   
    
  end

  # Code must be reviewed
  #Incomplete  code Start
  def self.edintity_cycle_total_stream(user,company)
    Stream.all(:conditions=> {:created_at =>user.cycle_start_date..user.cycle_start_date+2.month, :stream_id => nil, :is_deleted => nil,:company_id=>company} )
  end

  # end
  
  def self.save_twitter_status_stream_details(message_hash, service, brand )
    Stream.transaction do
      message_hash.each do |twit_stream|
        unless twit_stream["source"].index("edintity")
          if twit_stream["retweeted_status"]
            tweet = twit_stream["retweeted_status"]
            user = twit_stream["retweeted_status"]['user']
            text = tweet["text"] + " <br/>Retweeted by @#{twit_stream["user"]["screen_name"]}"
          else
            tweet = twit_stream
            user = twit_stream["user"]
            text = tweet["text"]
          end
          @stream = Stream.create!(:service_id => service.service.id,
            :user_service_id => service.id,
            :user_id => service.user_id,
            :brand_id => brand ? service.brand_id : nil,
            :company_id => brand ? service.company_id : nil,
            :stream_id => twit_stream["id_str"],
            :message_type_id => 2 ,#TODO has to create a model and assign correct type
            :text => text ,
            :is_displayed => 0,
            :stream_created_at => Time.parse(tweet["created_at"]) ,
            :sender_id => user["id_str"]
            #          :receiver_id => twit_stream["recipient_id"]
          )


          #      StreamDetail.create_stream_detail(twit_stream["sender"], @stream, "Sender")
          #      StreamDetail.create_stream_detail(twit_stream["recipient"], @stream, "Receiver")

          #TODO screen display name
          StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
            :name => user["name"],
            :user_name => user["screen_name"],
            :followers_count =>  user["followers_count"],
            :favourites_count => user["favourites_count"],
            :location =>  user["location"],
            :description =>  user["description"],
            :friends_count =>  user["friends_count"],
            :utc_offset =>  user["utc_offset"],
            :time_zone =>  user["time_zone"],
            :statuses_count => user["statuses_count"],
            :profile_image_url => user["profile_image_url"],
            :created_date => user["created_at"])

          #        StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Receiver",
          #          :name => twit_stream["recipient"]["name"],
          #          :followers_count =>  twit_stream["recipient"]["followers_count"],
          #          :favourites_count => twit_stream["recipient"]["favourites_count"],
          #          :location =>  twit_stream["recipient"]["location"],
          #          :description =>  twit_stream["recipient"]["description"],
          #          :friends_count =>  twit_stream["recipient"]["friends_count"],
          #          :utc_offset =>  twit_stream["recipient"]["utc_offset"],
          #          :time_zone =>  twit_stream["recipient"]["time_zone"],
          #          :statuses_count =>twit_stream["recipient"]["statuses_count"],
          #
          #          :profile_image_url => twit_stream["recipient"]["profile_image_url"],
          #          :created_date => twit_stream["recipient"]["created_at"]);
        end
      end
    end
  end

  def self.save_post_status_stream_details(service, info, star_count, retweet)
    Stream.transaction do
      @stream = Stream.create(:service_id => retweet ? service.service.id : nil,
        :user_service_id => service.id,
        :user_id => service.user_id,
        :stream_id => info["status"]["id"],
        :message_type_id => 2 ,
        :text => info["status"]["text"] ,
        :stream_created_at => Time.parse(info["status"]["created_at"]) ,
        :sender_id => info["id_str"],
        :post_type => 1,
        :is_displayed => 1,
        :retweeted => true
      )

      StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
        :name => info["name"],
        :user_name => service.user_name,
        :followers_count =>  info["followers_count"],
        :favourites_count => info["favourites_count"],
        :location =>  info["location"],
        :description =>  info["description"],
        :friends_count =>  info["friends_count"],
        :utc_offset =>  info["utc_offset"],
        :time_zone =>  info["time_zone"],
        :statuses_count => info["statuses_count"],
        :profile_image_url => info["profile_image_url"],
        :created_date => info["created_at"])
    end
    @stream
  end


  def self.save_twitter_stream_details(message_hash, service)
    Stream.transaction do
      message_hash.each do |twit_stream|
        @stream = Stream.create(:service_id => service.service.id,
          :user_service_id => service.id,
          :user_id => service.user_id,
          :stream_id => twit_stream["id"],
          :message_type_id => 1 ,#TODO has to create a model and assign correct type
          :text => twit_stream["text"] ,
          :is_sender_following => twit_stream["sender"]["following"] ,
          :is_receiver_following => twit_stream["recipient"]["following"],
          :sender_id => twit_stream["sender_id"] ,
          :is_displayed => 0,
          :receiver_id => twit_stream["recipient_id"]
        )


        #      StreamDetail.create_stream_detail(twit_stream["sender"], @stream, "Sender")
        #      StreamDetail.create_stream_detail(twit_stream["recipient"], @stream, "Receiver")

        #TODO screen display name
        StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
          :name => twit_stream["sender"]["name"],
          :followers_count =>  twit_stream["sender"]["followers_count"],
          :favourites_count => twit_stream["sender"]["favourites_count"],
          :location =>  twit_stream["sender"]["location"],
          :description =>  twit_stream["sender"]["description"],
          :friends_count =>  twit_stream["sender"]["friends_count"],
          :utc_offset =>  twit_stream["sender"]["utc_offset"],
          :time_zone =>  twit_stream["sender"]["time_zone"],
          :statuses_count =>twit_stream["sender"]["statuses_count"],
          :profile_image_url => twit_stream["sender"]["profile_image_url"],
          :created_date => twit_stream["sender"]["created_at"])

        StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Receiver",
          :name => twit_stream["recipient"]["name"],
          :followers_count =>  twit_stream["recipient"]["followers_count"],
          :favourites_count => twit_stream["recipient"]["favourites_count"],
          :location =>  twit_stream["recipient"]["location"],
          :description =>  twit_stream["recipient"]["description"],
          :friends_count =>  twit_stream["recipient"]["friends_count"],
          :utc_offset =>  twit_stream["recipient"]["utc_offset"],
          :time_zone =>  twit_stream["recipient"]["time_zone"],
          :statuses_count =>twit_stream["recipient"]["statuses_count"],

          :profile_image_url => twit_stream["recipient"]["profile_image_url"],
          :created_date => twit_stream["recipient"]["created_at"]);
      end
    end
  end

  def self.save_post_photo_stream_details(service, info, star_count)
    Stream.transaction do
      @stream = Stream.create(:service_id => service.service.id,
        :user_service_id => service.id,
        :user_id => service.user_id,
        :stream_id => info["id"].to_i,
        :message_type_id => 7,
        :text => info["description"],
        :stream_created_at => Time.at(info["dateuploaded"].to_i),
        :sender_id => info['owner']['nsid'],
        :flickr_photo_title => info['title'],
        :flickr_image_url => FlickRaw.url_s(info),
        :post_type => 7,
        :is_displayed => 1,
        :star_count => star_count
      )
      user = flickr.people.getInfo(:user_id => info['owner']['nsid'])
      StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
        :name => user['username'],
        :location =>  user["location"],
        :profile_image_url => "http://www.flickr.com/buddyicons/#{user['nsid']}.jpg",
        :created_date => Time.at(info["dateuploaded"].to_i)
      )
    end
    @stream
  end

  def self.save_edintity_photo_stream_details(info, user, user_service)
    stream_description = info["description"] == "Say something about your photo..." ? "" : info["description"]
    Stream.transaction do
      @stream = Stream.create(:service_id => nil,
        :user_id => user.id,
        :company_id => info["company_id"] ? info["company_id"]:"",
        :brand_id => info["brand_type"] ? info["brand_type"]:"",
        :message_type_id => 7,
        :text => stream_description,
        :flickr_photo_title => info['title'],
        :stream_created_at => Time.current,
        :sender_id => user.id,
        :post_type => 7,
        :is_displayed => 0,
        :star_count => info[:star1],
        :send_to => user_service ? user_service * "," : ""
      )
      StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
        :name => user.full_name,
        :time_zone =>  user.time_zone
      )
    end
    @stream
  end

  def self.save_edintity_video_stream_details(info, user, user_service)
    stream_description = info["description"] == "Say something about your video..." ? "" : info["description"]
    Stream.transaction do
      @stream = Stream.create(
        :user_id => user.id,
        :brand_id => info["brand_type"] ? info["brand_type"]:"",
        :company_id => info["company_id"] ? info["company_id"]:"",
        :message_type_id => 3,
        :text => stream_description,
        :flickr_photo_title => info['title'],
        :stream_created_at => Time.current,
        :sender_id => user.id,
        :post_type => 3,
        :is_displayed => 1,
        :star_count => info[:star1],
        :send_to => user_service ? user_service * "," : ""
      )
      StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
        :name => user.full_name,
        :time_zone =>  user.time_zone
      )
    end
    @stream
  end

  def self.save_edintity_blog_stream_details(info, user, type, services)
    blog_title = info['blog_title'] == "Blog title" ? "" : info['blog_title']
    blog_content = info['blog_content'] == "Write Your blog content here..." ? "" : info['blog_content']
    Stream.transaction do
      @stream = Stream.create(:service_id => nil,
        :user_id => user.id,
        :company_id => info["company_id"] ? info["company_id"]:"",
        :brand_id => info["brand_type"] ? info["brand_type"]:"",
        :message_type_id => 9,
        :tumblr_feed_type => type,
        :tumblr_data_one => blog_title,
        :tumblr_data_two => blog_content,
        :stream_created_at => Time.current,
        :sender_id => user.id,
        :post_type => 9,
        :is_displayed => 1,
        :star_count => info[:star1],
        :send_to => services ? services * "," : ""
      )
      StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
        :name => user.full_name,
        :time_zone =>  user.time_zone
      )
    end
    @stream
  end

  def self.save_edintity_stream_details(info, user, service, user_service)
    if info["stream_post_type"].downcase == "status"
      message = info["status_update_message"]
    else
      message = info["title"]
    end
    Stream.transaction do
      @stream = Stream.create(:service_id => nil,
        :user_id => user.id,
        :message_type_id => 1,
        :text => message,
        :topic_id => info["topic_id"],
        :description => info["description"],
        :stream_created_at => Time.current,
        :sender_id => user.id,
        :post_type => 1,
        :is_displayed => 1,
        :star_count => info[:star1],
        :send_to => user_service.join(","),
        :brand_id => info["brand_type"].blank? ? nil : info["brand_type"],
        :company_id => info["company_id"].blank? ? nil : info["company_id"]
      )
      StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
        :name => user.full_name,
        :time_zone =>  user.time_zone
      )
    end
    @stream
  end

  def self.save_edintity_link_stream_details(info, user, service, user_service)
    if info["stream_post_type"] == "Status Update"
      message = info["status_update_message"]
    elsif info["stream_post_type"] == "Link"
      message = "http://#{info["title"]}"
    else
      message = info["title"]
    end

    stream_description = info["description"] == "Say something about your link..." ? "" : info["description"]

    Stream.transaction do
      @stream = Stream.create(:service_id => nil,
        :user_id => user.id,
        :message_type_id => 1,
        :text => message,
        :description => stream_description,
        :stream_created_at => Time.current,
        :sender_id => user.id,
        :post_type => 3,
        :is_displayed => 1,
        :star_count => info[:star1],
        :send_to => user_service.join(","),
        :brand_id => info["brand_type"].blank? ? nil : info["brand_type"],
        :company_id => info["company_id"].blank? ? nil : info["company_id"]
      )
      StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
        :name => user.full_name,
        :time_zone =>  user.time_zone
      )
    end
    @stream
  end

  def self.save_flickr_stream_details(message_hash, service)
    Stream.transaction do
      message_hash.each do |flickr_pic|
        @stream = Stream.create(:service_id => 7,
          :user_service_id => service.id,
          :user_id => service.user_id,
          :stream_id => flickr_pic.id.to_i,
          :message_type_id => 7,#TODO has to create a model and assign correct type
          :text => flickr_pic.description,
          :is_sender_following => 0,
          :is_receiver_following => 0,
          :is_displayed => 0,
          :sender_id => flickr_pic.owner.nsid,
          :flickr_photo_title => flickr_pic.title,
          :flickr_image_url => FlickRaw.url_b(flickr_pic),
          :stream_created_at => Time.at(flickr_pic.dateuploaded.to_i)
        )

        #TODO screen display name
        StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
          :name => flickr_pic.owner.username,
          :location =>  flickr_pic.owner.location,
          :profile_image_url => "http://www.flickr.com/buddyicons/#{flickr_pic.owner.nsid}.jpg",
          :created_date => Time.now)

      end
    end
  end

  def self.save_rss_stream_details(feeds, user, service)
    last_updated = self.find_last_feed_date(user,service)
    Stream.transaction do
      feeds.each do |feed|
        if feed.published.to_i > last_updated.to_i
          @stream = Stream.create(
            :user_id => user.id,
            :message_type_id => 8,#TODO has to create a model and assign correct type
            :text => feed.title,
            :rss_original_site_content => feed.id,
            :is_sender_following => 0,
            :is_receiver_following => 0,
            :service_id => 8,
            :is_displayed => 1,
            :rss_link_id => service.id,
            :rss_feed_description => feed.summary,
            :stream_created_at => Time.at(feed.published.to_i)
          )

          #TODO screen display name
          StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
            :name => service.title,
            :created_date => Time.current)
        end
      end
    end
  end

  def self.save_vimeo_stream_details(video_base, videos, person, service, user)
    unless videos.blank?
      vimeo_upload_date = self.find_vimeo_upload_date(user,service)
      Stream.transaction do
        videos.each do |video|
          owner = person.get_info(video["owner"])
          video_info = video_base.get_info(video["id"])
          urls = video_info["video"][0]["urls"]["url"]
          vimeo_url = ""
          urls.each do |url|
            if url["type"] == "video"
              vimeo_url = url["_content"]
            end
          end
          uploaded_date = video["is_like"] == "1" ? video["liked_on"] : video["upload_date"]
          if vimeo_upload_date.nil? || Time.parse(uploaded_date).utc.to_i > vimeo_upload_date.utc.to_i
            user_id, company_id, brand_id = get_object_ids(user)
            @stream = Stream.create(
              :user_id => user_id,
              :message_type_id => 4,#TODO has to create a model and assign correct type
              :text => video["title"],
              :is_sender_following => 0,
              :is_receiver_following => 0,
              :is_displayed => 0,
              :service_id => 4,
              :user_service_id => service.id,
              :stream_id => video["id"].to_i,
              :sender_id => video["owner"].to_i,
              :video_url => vimeo_url,
              :stream_created_at => Time.parse(uploaded_date),
              :company_id => company_id,
              :brand_id => brand_id
            )

            #TODO screen display name
            profile_pics = owner["person"]["portraits"]["portrait"]
            StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
              :name => owner["person"]["display_name"],
              :location => owner["person"]["location"],
              :profile_image_url => profile_pics[profile_pics.length-1]["_content"],
              :description => owner['bio'],
              :created_date => Time.current)
          end
        end
      end
    end
  end

  def self.save_youtube_stream_details(videos, service, user, client)
    youtube_upload_date = self.find_youtube_upload_date(user,service)
    unless videos.include?(nil)
      Stream.transaction do
        videos.each do |video|
          unless video['group']['keywords'] == "edintity"
            owner_feed = client.get("http://gdata.youtube.com/feeds/api/users/#{video["group"]["credit"]}").body
            owner = Hash.from_xml(owner_feed)
            youtube_url = ""
            if video["link"][0].has_value?("alternate")
              youtube_url = video["link"][0]["href"]
            else
              video["link"].each do |link|
                if link.has_value?("alternate")
                  youtube_url = link["href"]
                end
              end
            end
            if youtube_upload_date.nil? || Time.parse(video["published"]).localtime.to_i > youtube_upload_date.to_i
              user_id, company_id, brand_id = get_object_ids(user)
              @stream = Stream.create(
                :user_id => user_id,
                :message_type_id => 3,#TODO has to create a model and assign correct type
                :text => video["title"],
                :is_sender_following => 0,
                :is_receiver_following => 0,
                :service_id => 3,
                :user_service_id => service.id,
                :stream_id => video["group"]["videoid"],
                :sender_id => video["group"]["credit"],
                :video_url => youtube_url,
                :is_displayed => 0,
                :stream_created_at => Time.parse(video["published"]).localtime,
                :company_id => company_id,
                :brand_id => brand_id
              )

              #TODO screen display name
              StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
                :name => video["group"]["credit"],
                :location => owner["entry"]["location"],
                :profile_image_url => owner["entry"]["thumbnail"]["url"],
                :created_date => Time.parse(owner["entry"]["published"]))
            end
          end
        end
      end
    end
  end

  def self.save_facebook_stream_details(client, service, user,brand)
    last_updated = self.find_last_fb_feed_date(user, service,brand)
    Stream.transaction do
      feeds = client.me.home['data']
      feeds.each do |feed|
        if last_updated.nil? || Time.parse(feed['created_time']).utc.to_i > last_updated.utc.to_i+60
          @stream = Stream.create(:service_id => service.service.id,
            :user_service_id => service.id,
            :user_id => service.user_id,
            :brand_id => brand == true ? service.brand_id : nil,
            :company_id => brand== true ? service.company_id : nil,
            :stream_id => feed['id'].gsub("#{feed['from']['id']}_",""),
            :message_type_id => 2,#TODO has to create a model and assign correct type
            :text => feed['message'],
            :is_sender_following => 0,
            :is_receiver_following => 0,
            :is_displayed => 0,
            :sender_id => feed['from']['id'],
            :facebook_link_url => feed['type'] == "photo" ? feed['picture'].gsub("_s.jpg","_n.jpg") : feed['link'],
            :facebook_feed_type => feed['type'],
            :facebook_feed_description => feed['description'],
            :stream_created_at => Time.parse(feed['created_time'])

          )

          StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
            :name => feed['from']['name'],
            :profile_image_url => "http://graph.facebook.com/#{feed['from']['id']}/picture"
          )
        end
      end
    end
  end

  def self.save_facebook_page_stream_details(client, service, user,brand)
    last_updated = self.find_last_fb_page_feed_date(user, service,brand)
    Stream.transaction do
      feeds = client.page(service.fb_page_id).feed['data']
      feeds.each do |feed|
        if last_updated.nil? || Time.parse(feed['created_time']).utc.to_i > last_updated.utc.to_i+60
          @stream = Stream.create(:service_id => service.service.id,
            :user_service_id => service.id,
            :user_id => service.user_id,
            :brand_id => brand == true ? service.brand_id : nil,
            :company_id => brand== true ? service.company_id : nil,
            :stream_id => feed['id'].to_i,
            :message_type_id => 2,#TODO has to create a model and assign correct type
            :text => feed['message'],
            :is_sender_following => 0,
            :is_receiver_following => 0,
            :is_displayed => 0,
            :sender_id => feed['from']['id'],
            :facebook_link_url => feed['link'],
            :facebook_feed_type => feed['type'],
            :facebook_feed_description => feed['description'],
            :stream_created_at => Time.parse(feed['created_time'])

          )

          StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
            :name => feed['from']['name'],
            :profile_image_url => "http://graph.facebook.com/#{feed['from']['id']}/picture"
          )
        end
      end
    end
  end

  def self.save_tumblr_stream_details(feeds, service, user, info)
    last_updated = self.find_last_tumblr_feed_date(user, service)
    Stream.transaction do
      feeds.each do |feed|
        feed_data = self.parse_tumblr_data(feed)
        if last_updated.nil? || Time.parse(feed["date_gmt"]).utc.to_i > last_updated.utc.to_i+60
          feed_data[:one] = feed_data[:one].first if feed_data[:type] == "video" && feed_data[:one].kind_of?(Array)
          user_id, company_id, brand_id = get_object_ids(user)
          @stream = Stream.create(:service_id => service.service.id,
            :user_service_id => service.id,
            :user_id => user_id,
            :stream_id => feed['id'].to_i,
            :message_type_id => 9,#TODO has to create a model and assign correct type
            :is_sender_following => 0,
            :is_receiver_following => 0,
            :tumblr_feed_type => feed_data[:type],
            :tumblr_data_one => feed_data[:one],
            :tumblr_data_two => feed_data[:two],
            :video_url => feed_data[:three],
            :is_displayed => 0,
            :stream_created_at => Time.parse(feed['date_gmt']),
            :description => feed_data[:desc],
            :company_id => company_id,
            :brand_id => brand_id
          )

          StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
            :name => info['title'],
            :time_zone => info["timezone"]
          )
        end
      end
    end
  end

  def self.save_delicious_stream_details(feeds, service, user)
    last_updated = self.find_last_delicious_feed_date(user, service)
    Stream.transaction do
      feeds.each do |feed|
        if last_updated.nil? || feed.published.to_i > last_updated.utc.to_i
          user_id, company_id, brand_id = get_object_ids(user)
          @stream = Stream.create(:service_id => service.service.id,
            :user_service_id => service.id,
            :user_id => user_id,
            :stream_id => feed.id.gsub("http://www.delicious.com/url/", "").gsub("##{service.token}", ""),
            :message_type_id => 5,#TODO has to create a model and assign correct type
            :is_sender_following => 0,
            :is_receiver_following => 0,
            :stream_created_at => Time.at(feed.published.to_i),
            :rss_feed_description => feed.summary,
            :text => feed.title,
            :is_displayed => 0,
            :rss_original_site_content => feed.url,
            :company_id => company_id,
            :brand_id => brand_id
          )

          StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
            :name => feed.author
          )
        end
      end
    end
  end

  def self.save_stumbleupon_stream_details(feeds, service, user)
    last_updated = self.find_last_stumbleupon_feed_date(user, service)
    Stream.transaction do
      feeds.each do |feed|
        if last_updated.nil? || feed.published.to_i > last_updated.utc.to_i
          summary = feed.summary.blank? ? feed.summary : feed.summary.gsub("href=","target='_blank' href=")
          user_id, company_id, brand_id = get_object_ids(user)
          @stream = Stream.create(:service_id => service.service.id,
            :user_service_id => service.id,
            :user_id => user_id,
            :stream_id => feed.id,
            :message_type_id => 6,#TODO has to create a model and assign correct type
            :is_sender_following => 0,
            :is_receiver_following => 0,
            :stream_created_at => Time.at(feed.published.to_i),
            :rss_feed_description => summary,
            :text => feed.title,
            :is_displayed => 0,
            :rss_original_site_content => feed.url,
            :company_id => company_id,
            :brand_id => brand_id
          )

          StreamDetail.create(:stream_id => @stream.id, :streamable_type => "Sender",
            :name => service.profile_name
          )
        end
      end
    end
  end

  def self.find_since_id(user,service)
    stream_id = user.streams.maximum("CAST(stream_id AS UNSIGNED)", :conditions => ["user_service_id =?",service.id])
    if !stream_id.blank?
      return stream_id
    end
  end

  def self.find_since_id_brand(brand,service)
    stream_id = brand.streams.maximum("CAST(stream_id AS UNSIGNED)", :conditions => ["brand_service_id =?",service.id])
    if !stream_id.blank?
      return stream_id
    end
  end

  def self.find_vimeo_upload_date(user,service)
    vimeo_upload_date = user.streams.maximum(:stream_created_at, :conditions => ["user_service_id =?",service.id])
    return vimeo_upload_date
  end

  def self.find_youtube_upload_date(user,service)
    youtube_upload_date = user.streams.maximum(:stream_created_at, :conditions => ["user_service_id =?",service.id])
    return youtube_upload_date
  end

  def self.find_last_tumblr_feed_date(user,service)
    last_date = user.streams.maximum(:stream_created_at, :conditions => ["user_service_id =? or (send_to like '?,%' or send_to like '%,?' or send_to like '%,?,%' or send_to = '?')",service.id,service.id,service.id,service.id,service.id])
    return last_date
  end

  def self.find_last_delicious_feed_date(user,service)
    last_date = user.streams.maximum(:stream_created_at, :conditions => ["user_service_id =? or (send_to like '?,%' or send_to like '%,?' or send_to like '%,?,%' or send_to = '?')",service.id,service.id,service.id,service.id,service.id])
    return last_date
  end

  def self.find_last_stumbleupon_feed_date(user,service)
    last_date = user.streams.maximum(:stream_created_at, :conditions => ["user_service_id =? or (send_to like '?,%' or send_to like '%,?' or send_to like '%,?,%' or send_to = '?')",service.id,service.id,service.id,service.id,service.id])
    return last_date
  end
  #TODO code must be reviewed
  def self.find_last_upload_date(user,service,brand)
    if brand == true
      flickr_upload_date = user.streams.maximum(:stream_created_at, :conditions => ["brand_service_id =? or (service_id = 7 and (send_to like '?,%' or send_to like '%,?' or send_to like '%,?,%' or send_to = '?' ))",service.id,service.id,service.id,service.id,service.id])
    else
      flickr_upload_date = user.streams.maximum(:stream_created_at, :conditions => ["user_service_id =? or (service_id = 7 and (send_to like '?,%' or send_to like '%,?' or send_to like '%,?,%' or send_to = '?' ))",service.id,service.id,service.id,service.id,service.id])
    end
    return flickr_upload_date
  end
  #end
  def self.find_last_feed_date(user,service)
    last_feed_date = user.streams.maximum(:stream_created_at, :conditions => ["service_id = 8 and rss_link_id = ?",service.id])
    return last_feed_date
  end

  def self.find_last_fb_feed_date(user, service,brand)
    if brand == true
      last_feed_date = user.streams.maximum(:stream_created_at, :conditions => ["service_id = 2 and brand_service_id = ? or (send_to like '?,%' or send_to like '%,?' or send_to like '%,?,%' or send_to = '?' )",service.id,service.id,service.id,service.id,service.id])
    else
      last_feed_date = user.streams.maximum(:stream_created_at, :conditions => ["service_id = 2 and user_service_id = ? or (send_to like '?,%' or send_to like '%,?' or send_to like '%,?,%' or send_to = '?' )",service.id,service.id,service.id,service.id,service.id])
    end

    #    feed_date2 = user.streams.maximum(:stream_created_at, :conditions => ["(service_id is null and  user_service_id = ? and INSTR(send_to, 2))", service.id])
    #    if feed_date1 != nil and feed_date2 != nil
    #      last_feed_date = feed_date1 > feed_date2 ? feed_date1: feed_date2;
    #    elsif feed_date1 == nil
    #      last_feed_date = feed_date2
    #    else
    #      last_feed_date = feed_date1
    #    end
    return last_feed_date
  end

  def self.find_last_fb_page_feed_date(user, service,brand)
    if brand == true
      last_feed_date = user.streams.maximum(:stream_created_at, :conditions => ["service_id = 10 and brand_service_id = ? or (send_to like '?,%' or send_to like '%,?' or send_to like '%,?,%' or send_to = '?' )",service.id,service.id,service.id,service.id,service.id])
    else
      last_feed_date = user.streams.maximum(:stream_created_at, :conditions => ["service_id = 10 and user_service_id = ? or (send_to like '?,%' or send_to like '%,?' or send_to like '%,?,%' or send_to = '?' )",service.id,service.id,service.id,service.id,service.id])
    end
    return last_feed_date
  end

  def self.find_recent_records_from_db

  end

  def stream_media_url
    case self.service_id
    when 7 then
      self.flickr_image_url
    when 2 then
      self.facebook_link_url
    else
      ""
    end
  end
  #  def self.find_followings_whom_shared_services(user)
  #    # Posted to edintity
  #    if user.privacy_type_id.to_i == 1 or user.privacy_type_id.to_i == 3 # Shared to everyone or Followings
  #      user.streams.find(:all, :include => ["user_service"], :conditions => "streams.service_id is null and streams.is_deleted is null")
  #    end
  #
  #
  #    # Posted to services
  #    #TODO
  #  end
  #
  #
  #
  #  def self.find_followers_whom_shared_services(user)
  #    if user.privacy_type_id.to_i == 1 or user.privacy_type_id.to_i == 2 # Shared to everyone or Followers
  #      user.streams.find(:all, :include => ["user_service"], :conditions => "streams.service_id is null and streams.is_deleted is null")
  #
  #    end
  #    #    follower =  followers.join(",")
  #    #    self.find(:all, :include => ["user_service"], :conditions => "streams.user_id in (#{follower}) ")
  #  end
  #
  #  def self.find_friends_whom_shared_services(user)
  #    if user.privacy_type_id.to_i == 1 or user.privacy_type_id.to_i == 4 # Shared to everyone or Friends
  #      user.streams.find(:all, :include => ["user_service"], :conditions => "streams.service_id is null and streams.is_deleted  is null")
  #    end
  #    #    friend =  friends.join(",")
  #    #    self.find(:all, :include => ["user_service"], :conditions => "streams.user_id in (#{friend})")
  #  end
  #
  #  def self.get_streams_followers_followings(user)
  #    if user.privacy_type_id.to_i == 1 or user.privacy_type_id.to_i == 2 or user.privacy_type_id.to_i == 3
  #      user.streams.find(:all, :include => ["user_service"], :conditions => "streams.service_id is null and streams.is_deleted is null")
  #    end
  #  end
  #
  #  def self.get_streams_followers_friends(user)
  #    if user.privacy_type_id.to_i == 1 or user.privacy_type_id.to_i == 4 or user.privacy_type_id.to_i == 2
  #      user.streams.find(:all, :include => ["user_service"], :conditions => "streams.service_id is null and streams.is_deleted is null")
  #    end
  #  end
  #
  #  def self.get_streams_followers_username(user,username)
  #    if user.privacy_type_id.to_i == 1 or user.privacy_type_id.to_i == 2
  #      user.streams.find(:all, :include => ["user_service"], :conditions => "streams.service_id is null and streams.is_deleted is null")
  #    end
  #  end
  #
  #  def self.get_streams_followings_friends(user)
  #    if user.privacy_type_id.to_i == 1 or user.privacy_type_id.to_i == 4 or user.privacy_type_id.to_i == 3
  #      user.streams.find(:all, :include => ["user_service"], :conditions => "streams.service_id is null and streams.is_deleted is null")
  #    end
  #  end
  #
  #  def self.get_streams_followings_username(user,username)
  #    if user.privacy_type_id.to_i == 1 or  user.privacy_type_id.to_i == 3
  #      user.streams.find(:all, :include => ["user_service"], :conditions => "streams.service_id is null and streams.is_deleted is null")
  #    end
  #  end
  #
  #  def self.get_streams_friends_username(user,username)
  #    if user.privacy_type_id.to_i == 1 or user.privacy_type_id.to_i == 4
  #      user.streams.find(:all, :include => ["user_service"], :conditions => "streams.service_id is null and streams.is_deleted is null")
  #    end
  #  end
  #
  #  def self.get_streams_with_user_name(user,username)
  #    user.streams.find(:all, :include => ["user_service"], :conditions => "streams.service_id is null and streams.is_deleted is null")
  #  end



  def flickr_full_url
    self.flickr_image_url.gsub('_s.', '.')
  end

  def video
    begin
      UnvlogIt.new(self.video_url)
    rescue Exception => e
      return e.message
    end
  end

  def fb_video
    begin
      UnvlogIt.new(self.facebook_link_url)
    rescue Exception => e
      return e.message
    end
  end

  def self.parse_tumblr_data(feed)
    data = {}
    case feed["type"].upcase
    when "REGULAR" then
      data[:type] = feed["type"]
      data[:one] = feed["regular_title"]
      data[:two] = feed["regular_body"]
    when "LINK" then
      data[:type] = feed["type"]
      data[:one] = feed["link_text"]
      data[:two] = feed["link_url"]
      data[:desc] = feed["link_description"]
    when "QUOTE" then
      data[:type] = feed["type"]
      data[:one] = feed["quote_text"]
      data[:two] = feed["quote_source"]
    when "PHOTO" then
      data[:type] = feed["type"]
      data[:one] = feed["photo_url"][2]
      data[:two] = feed["photo_caption"]
    when "CONVERSATION" then
      data[:type] = feed["type"]
      data[:one] = feed["conversation_title"]
      data[:two] = feed["conversation_text"].gsub("\n", "<br/>")
    when "VIDEO" then
      data[:type] = feed["type"]
      data[:one] = feed["video_player"]
      data[:two] = feed["video_caption"]
      data[:three] = feed["url_with_slug"]
    when "AUDIO" then
      data[:type] = feed["type"]
      data[:one] = feed["audio_player"]
      data[:two] = feed["audio_caption"]
    end
    return data
  end

  def stream_tags_array
    self.stream_tags.collect{|stream_tag| stream_tag.tag.name}
  end

  def stream_tags_string
    self.stream_tags_array.join(",")
  end

  def stream_tags_array_with_id
    self.stream_tags.collect{|stream_tag| [stream_tag.id, stream_tag.tag.name]}
  end

  def self.displayed_streams(user, follower)
    streams = []
    #user_privacy_setting = user.read_or_create_privacy_setting
    follower_privacy_groups = follower.blank? ? [User::PRIVACY_TYPES[:every_one].to_s] : follower.member_of_privacy_groups_of(user)
    streams = Stream.find(:all, :include => [{:user => [:user_privacy_setting]}, {:user_service => [:service]}], :conditions => [
        "(streams.user_id in (?) AND
          ((user_privacy_settings.stream in (?) AND streams.user_service_id is null AND streams.service_id is null) OR
           (user_privacy_settings.stream in (?) AND streams.user_service_id is null AND streams.service_id in (3)) OR
           (user_privacy_settings.rss in (?) AND streams.service_id in (8)) OR
            (user_services.privacy_type_id in (?) AND streams.service_id not in (8) AND streams.user_service_id is not null AND streams.service_id is not null)) AND
              streams.is_deleted is null AND streams.brand_id is null AND streams.company_id is null) ",
        user.id, follower_privacy_groups, follower_privacy_groups, follower_privacy_groups, follower_privacy_groups], :order => "stream_created_at DESC")
    #    user.streams.each do |stream|
    #      if stream.can_be_viewed_by(user_privacy_setting, follower_privacy_groups)
    #        streams << stream
    #      end
    #    end
    streams
    #raise "#{streams.size} #{follower_privacy_groups} "
  end


  def can_be_viewed_by(user_privacy_setting, follower_privacy_groups)
    can_be_viewed = false
    if self.user_service
      if follower_privacy_groups.include?(self.user_service.privacy_type_id)
        can_be_viewed = true
      end
    else
      if follower_privacy_groups.include?(user_privacy_setting.stream)
        can_be_viewed = true
      end
    end
    can_be_viewed
  end

  def can_be_viewed(current_user)
    user_privacy_setting = self.user.read_or_create_privacy_setting
    follower_privacy_groups = current_user.member_of_privacy_groups_of(self.user)
    self.can_be_viewed_by(user_privacy_setting, follower_privacy_groups)
  end

  def stream_action
    unless self.user_service.blank?
      self.user.create_user_service_stream_actions
      self.user.default_stream_action
    else
      self.user.read_or_create_stream_actions
    end
  end

  def self.get_object_ids(user)
    if user.kind_of?(User)
      return [user.id, nil, nil]
    elsif user.kind_of?(Brand)
      return [user.company.user_id, user.company.id, user.id ]
    elsif user.kind_of?(Company)
      return [user.user_id, user.id, user.default_brand.id]
    end
  end

  def self.get_usage_stats(service_id = nil)
    unless service_id.blank?
      streams = self.find(:all, :joins => [:assets], :select => " sum(ifnull(assets.asset_file_size, 0) + ifnull(assets.video_file_size, 0)) as asset_size", :conditions => ["#{service_id == "edintity" ? "streams.service_id is null" : "streams.service_id = #{service_id}" } "] )
    else
      streams = self.find(:all, :joins => [:assets], :select => " sum(ifnull(assets.asset_file_size, 0) + ifnull(assets.video_file_size, 0)) as asset_size" )
    end
    streams.blank? ? 0 : streams.first.asset_size
  end

  def self.get_count_stats(service_id = nil)
    unless service_id.blank?
      service_id = 
        self.count(:all, :conditions => ["#{service_id == "edintity" ? "streams.service_id is null" : "streams.service_id = #{service_id}" } "] )
    else
      self.count(:all)
    end    
  end

  def self.get_usage_stats_by_post_type(post_id = nil)
    unless post_id.blank?
      streams = self.find(:all, :joins => [:assets], :select => " sum(ifnull(assets.asset_file_size, 0) + ifnull(assets.video_file_size, 0)) as asset_size", :conditions => ["streams.post_type = ? ", post_id] )
    else
      streams = self.find(:all, :joins => [:assets], :select => " sum(ifnull(assets.asset_file_size, 0) + ifnull(assets.video_file_size, 0)) as asset_size" )
    end
    streams.blank? ? 0 : streams.first.asset_size
  end

  def update_membership
    begin
      membership = self.brand.blank? ? self.user.membership_id : self.brand.company.membership_id
      self.update_attribute(:membership_id, membership)
    rescue

    end
  end

  def recent_comments
    self.comments.find(:all, :order => "id DESC", :limit => 3)
  end

  def get_twitter_replies
    replies = []
    if service = self.user_service
      mentions = TwitterAccount.get_mentions(service, self)
      unless mentions.blank?
        mentions['results'].each do |mention|
          if self.stream_id == mention['in_reply_to_status_id_str'] && !mention['source'].index("edintity")
            replies << mention
          end
        end
      end
    end
    replies
  end

  def self.save_and_share_to_services(params, current_user, brand = nil)
    unless params[:post_group_user_service_id].blank?
      post_user_list = params[:post_group_user_service_id]*(",")
      user_service_list = params[:serviceid].to_a.concat(post_user_list.split(",")).uniq
    else
      user_service_list = params[:serviceid].to_a
    end
    params[:stream] = params[:stream].merge({:service_id => nil,
        :stream_created_at => Time.current,
        :sender_id => current_user.id,
        :post_type => 1,
        :is_displayed => 1,
        :send_to => user_service_list.join(",")})

    stream = current_user.streams.new( params[:stream])
    if stream.save
      unless stream.topic_id.blank?
        Activity.add_points(current_user, Activity::ACTIVITY_TYPES[:post_to_topic], 'Stream', stream.id, nil, stream.topic_id)
      end
      StreamDetail.create(:stream_id => stream.id, :streamable_type => "Sender",
        :name => current_user.full_name,
        :time_zone =>  current_user.time_zone
      )

      if user_service_list.present?
        Post.post_to_services(self, params,current_user,user_service_list,brand)
      end
      return true
    else
      return false
    end
  end
end

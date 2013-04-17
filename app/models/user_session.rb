class UserSession < Authlogic::Session::Base
  generalize_credentials_error_messages false
  CONSUMER_KEY = "574635b9dd84d078557c32e2e96911de"
  CONSUMER_SECRET = "7d717f5ef44a4426"

  before_validation :verify_user

  def verify_user
    user = User.find_by_email(self.email)
    unless user.blank?
      self.errors.add(:base, "You account is not active, please contact support") if user.is_spammer 
    end
  end
  
  def self.find_tab_from_db(value)
    tab = Tab.find(value)
    return tab
  end

  #TODO Code to be reviewed
  def self.get_twitter_messages(current_user)
    messages_hash = []
    errors = []
    if current_user.class == User
      @service = current_user.user_services.twitter_authorized
      brand = false
    else
      @service = current_user.brand_services.twitter_authorized
      brand = true
    end
    @service.each do |service|
      begin
        messages_hash_new, errors_new = TwitterAccount.receive_status_messages(service, brand)
        messages_hash.concat(messages_hash_new)
        errors << errors_new unless errors_new.blank?
      rescue Exception => e
        raise e.inspect
      end
    end
    [messages_hash, errors.compact.join("<br />")]
  end
  #end
  def self.get_flickr_messages(current_user)
    if current_user.class == User
      @service = current_user.user_services.flickr_authorized
      brand = false
    else
      @service = current_user.brand_services.flickr_authorized
      brand = true
    end
    @service.each do |service|
      begin
        if service.service_id.to_i == 7
          flickr.auth.checkToken(:auth_token => service.token)
          @info = []
          last_upload_date = Stream.find_last_upload_date(current_user, service,brand)
          flickr.photos.search(:user_id => service.user_name, :min_upload_date => last_upload_date.to_i+120).each do |p|
            @info << flickr.photos.getInfo(:photo_id => p.id)
          end
          Stream.save_flickr_stream_details(@info,service)
        end
      rescue
      end
    end
  end

  def self.get_facebook_messages(current_user)
    if current_user.class == User
      @service = current_user.user_services.facebook_authorized
      brand = false
    else
      @service = current_user.brand_services.facebook_authorized
      brand = true
    end
    @service.each do |service|
      begin
       
        client = self.fb_client(service.token)
       
        Stream.save_facebook_stream_details(client, service, current_user,brand)
      rescue
      end
    end
  end

  def self.get_facebook_comments(stream, service)
    begin
      client = self.fb_client(service.token)
      comments = client.post(stream.stream_id).comments()
      comments["data"]
    rescue Exception => e
      []
    end
  end

  def self.post_facebook_comment(stream, service, comment)
    begin
      client = self.fb_client(service.token)
      puts "***********************************"
      puts client
      client.post(stream.stream_id).comments(:create, :message => comment)
    rescue Exception => e
    end
  end

  def self.get_facebook_page_messages(current_user)
    if current_user.class == User
      @service = current_user.user_services.facebook_page_authorized
      brand = false
    else
      @service = current_user.brand_services.facebook_page_authorized
      brand = true
    end
    @service.each do |service|
      begin

        client = self.fb_client(service.token)

        Stream.save_facebook_page_stream_details(client, service, current_user,brand)
      rescue
      end
    end
  end

  def self.get_vimeo_videos(current_user)
    services = current_user.kind_of?(Brand) || current_user.kind_of?(Company) ? current_user.brand_services : current_user.user_services
    services.vimeo_authorized.each do |service|
      #begin
      video = Vimeo::Advanced::Video.new(CONSUMER_KEY, CONSUMER_SECRET, :token => service.token, :secret => service.secret)
      person = Vimeo::Advanced::Person.new(CONSUMER_KEY, CONSUMER_SECRET, :token => service.token, :secret => service.secret)
      likes = video.get_likes(service.user_name)
      uploaded = video.get_all(service.user_name)
      if likes["videos"]["video"]
        if uploaded["videos"]["video"]
          videos = likes["videos"]["video"] + uploaded["videos"]["video"]
        else
          videos = likes["videos"]["video"]
        end
      end
      Stream.save_vimeo_stream_details(video, videos, person, service, current_user)
      #rescue
      #end
    end
  end

  def self.get_youtube_videos(current_user)
    services = current_user.kind_of?(Brand) || current_user.kind_of?(Company) ? current_user.brand_services : current_user.user_services
    services.youtube_authorized.each do |service|
      #      begin
      client = GData::Client::YouTube.new
      client.authsub_token = service.token
      videos = client.get('http://gdata.youtube.com/feeds/api/users/default/uploads').body
      new_videos_hash = Hash.from_xml(videos)
      favorites = client.get('http://gdata.youtube.com/feeds/api/users/default/favorites').body
      new_favorites_hash = Hash.from_xml(favorites)
      new_videos = new_videos_hash["feed"]["entry"].class == Array ? new_videos_hash["feed"]["entry"] : [new_videos_hash["feed"]["entry"]]
      new_favorites = new_favorites_hash["feed"]["entry"].class == Array ? new_favorites_hash["feed"]["entry"] : [new_favorites_hash["feed"]["entry"]]
      all_videos = new_videos + new_favorites
      Stream.save_youtube_stream_details(all_videos, service, current_user, client)
      #      rescue
      #      end
    end
  end

  def self.get_tumblr_messages(current_user)
    services = current_user.kind_of?(Brand) || current_user.kind_of?(Company) ? current_user.brand_services : current_user.user_services
    services.tumblr_authorized.each do |service|
      begin
        user_name = service.user_name.gsub("http://", "").split(".").first
        blog_info = RestClient.get("http://api.tumblr.com/v2/blog/#{user_name}.tumblr.com/info?api_key=WbI41IN94GLiSkleeWpUbX7cys2xz3Ul6ioFSJs9Zni1ppnugm")
        if blog_info
          json_info = ActiveSupport::JSON.decode(blog_info)
          info = json_info['response']['blog']
        else
          info = {:title => service.user_name}
        end
        Tumblr.blog = user_name
        blog_data = Tumblr::Request.read
        posts = blog_data["tumblr"]["posts"]["post"]
        Stream.save_tumblr_stream_details(posts, service, current_user, info)
      rescue Exception => e
      end
    end
  end

  def self.get_delicious_messages(current_user)
    services = current_user.kind_of?(Brand) || current_user.kind_of?(Company) ? current_user.brand_services : current_user.user_services
    services.delicious_authorized.each do |service|
      begin
        url = "http://feeds.delicious.com/v2/rss/#{service.token}?count=100"
        feeds = Feedzirra::Feed.fetch_and_parse(url)
        unless feeds == 0
          rss_feeds = feeds.sanitize_entries!
          Stream.save_delicious_stream_details(rss_feeds.entries, service, current_user) if feeds
        end
      rescue Exception => e
        #        logger.info e
      end
    end
  end

  def self.get_stumbleupon_messages(current_user)
    services = current_user.kind_of?(Brand) || current_user.kind_of?(Company) ? current_user.brand_services : current_user.user_services
    services.stumbleupon_authorized.each do |service|
      begin
        url = "http://rss.stumbleupon.com/user/#{service.token}/"
        feeds = Feedzirra::Feed.fetch_and_parse(url)
        unless feeds == 0
          rss_feeds = feeds.sanitize_entries!
          Stream.save_stumbleupon_stream_details(rss_feeds.entries, service, current_user) if feeds
        end
      rescue Exception => e
        #        logger.info e
      end
    end
  end

  def self.fb_client(token)
    @client = FacebookOAuth::Client.new(
      :application_id => '152688064798273',
      :application_secret => '2a0d1f86bb9462039bdc4fc265982ac7',
      :callback => 'http://edintity.com/',
      :token => token
    )
  end

  def self.post_fb_messages
    fb_client(token)
    client.me.feed(:create, :message => 'status')
  end

  def self.tumblr_access_token(token, secret)
    consumer = OAuth::Consumer.new('WbI41IN94GLiSkleeWpUbX7cys2xz3Ul6ioFSJs9Zni1ppnugm', 'NrWBAtzJq1XOkSERRygerdxxEOrmV3sbj5kmP9R5dSvlWiamUG',{:site => "http://www.tumblr.com/",
        :request_token_path => '/oauth/request_token',
        :authorize_path => '/oauth/authorize',
        :access_token_path => '/oauth/access_token',
        :http_method => :post})
    token_hash = {:oauth_token => token,:oauth_token_secret => secret}
    OAuth::AccessToken.from_hash(consumer, token_hash )
	end
end

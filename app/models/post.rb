class Post < ActiveRecord::Base

  require 'youtube_it'

  belongs_to :user
  belongs_to :brand
  belongs_to :post_type
  has_and_belongs_to_many :services
  
  CONSUMER_KEY = "574635b9dd84d078557c32e2e96911de"
  CONSUMER_SECRET = "7d717f5ef44a4426"
  DEV_KEY = "AI39si7vSgaZS6UktK6kMEZsfyaErDyqmx7YKw7JlweCPHEVTVDUDax_gx9yF7FU2YnNyv92KsyvZx_ClN8LMZI-V7THqEgjHw"


  def self.post_twitter_messages(params,current_user)
    message = params[:status_update_message]
    current_user.user_services.twitter_authorized.each do |service|
      TwitterAccount.post_twitter_message(message,service,params[:star1])
    end
  end
  #TODO
  # Need to make it dry with post_twitter_messages
  def self.post_to_services(stream ,params,current_user,services_ary,brand)
    if brand
      check_brand_service(stream, params,current_user,services_ary)
    else
      check_service(stream, params,current_user,services_ary)
    end
    
  end

  def self.post_blog_to_service(params,service)
    if service.service_id.to_i == 1
      self.post_blog_to_twitter(params, service)
    elsif service.service_id.to_i == 2
      self.post_blog_to_facebook(params, service)
    elsif service.service_id.to_i == 10
      self.post_blog_to_facebook_page(params, service)
    end
  end

  def self.post_video_to_service(params,service,file,url,stream,host)
    if service.service_id.to_i == 1
      self.post_video_to_twitter(params, service,stream,host)
    elsif service.service_id.to_i == 2
      self.post_video_to_facebook(params,service,file)
    elsif service.service_id.to_i == 10
      self.post_video_to_facebook_page(params,service,file)
    elsif service.service_id.to_i == 9
      self.post_video_to_tumblr(params,service,url)
    elsif service.service_id == 4
      self.post_video_to_vimeo(params,service)
    elsif service.service_id == 3
      self.post_video_to_youtube(params,service,file)
    end
  end

  def self.post_photo_to_service(params,service,file,url,stream)
    if service.service_id.to_i == 1
      self.post_photo_to_twitter(params, service,url,stream)
    elsif service.service_id.to_i == 2
      self.post_photo_to_facebook(params,service,file)
    elsif service.service_id.to_i == 10
      self.post_photo_to_facebook_page(params,service,file,url)
    elsif service.service_id.to_i == 9
      self.post_photo_to_tumblr(params,service,url)
    end
  end
  # Checking to identify service type
  def self.check_service(stream, params,current_user,services_ary)
    services_ary.each do |service_id|
      if UserService.find(service_id).service_id.to_i == 1
        self.post_to_twitter(stream, params,current_user,service_id)
      elsif UserService.find(service_id).service_id.to_i == 9
        self.post_to_tumblr(params,current_user,service_id)
      elsif UserService.find(service_id).service_id.to_i == 10
        self.post_to_facebook_page(params,current_user,service_id)
      elsif UserService.find(service_id).service_id.to_i == 2
        self.post_to_facebook(stream, params,current_user,service_id)
      end
    end
  end
  # Checking to identify brand service type
  def self.check_brand_service(stream, params,current_user,services_ary)
    services_ary.each do |service_id|
      if BrandService.find(service_id).service_id.to_i == 1
        self.post_to_twitter(params,current_user,service_id,false,true)
      elsif BrandService.find(service_id).service_id.to_i == 9
        self.post_to_tumblr(params,current_user,service_id)
      elsif BrandService.find(service_id).service_id.to_i == 10
        self.post_to_facebook_page(params,current_user,service_id,true)
      else
        self.post_to_facebook(params,current_user,service_id,true)
      end
    end
  end
  # Share to service with Twitter
  def self.post_to_twitter(stream, params,current_user,service_id,retweet=false,brand=false)
    if (params["stream_post_type"] && params["stream_post_type"].downcase == "status") || params[:stream][:message_type_id].to_i == 1
      #message = params["status_update_message"]
      #if message.length > 140
      #  url = "https://www.edintity.com/stream/#{params["stream"].id}"
      #  message = "#{message[0,105]}... read more #{self.shorten_bitly(url)}"
      #end
      url = "https://www.edintity.com/stream/#{stream.id}"
      message = "#{params['status_optional_message'].to_s[0,105]} #{self.shorten_bitly(url)}"
    else
      #message = params[:title]
      message = ""
    end
    if brand
      service = current_user.brand_services.twitter_authorized.find(service_id.to_i)
    else
      service = current_user.user_services.twitter_authorized.find(service_id.to_i)
    end
    TwitterAccount.post_twitter_message(message,service,params[:star1],retweet, params["stream"])
  end

  def self.post_blog_to_twitter(params,service)
    message = params[:blog_title] + " - " + params[:blog_content]
    TwitterAccount.post_twitter_message(message,service,params[:star1])
  end

  def self.post_blog_to_facebook(params,service)
    client = UserSession.fb_client(service.token)
    client.me.notes(:create, :message => params[:blog_content], :subject => params[:blog_title] )
  end

  def self.post_blog_to_facebook_page(params,service)
    client = UserSession.fb_client(service.secret)
    client.page(service.fb_page_id).notes(:create, :message => params[:blog_content], :subject => params[:blog_title] )
  end

  def self.post_photo_to_facebook(params,service,file)
    begin
      client = UserSession.fb_client(service.token)
      post_args = { 'message' => params[:description], :access_token => service.token , :source => file}
      RestClient.post("https://graph.facebook.com/#{client.me.info['id']}/photos", post_args)
    rescue Exception => e
    end
  end

  def self.post_photo_to_facebook_page(params,service,file,url)
    begin
      client = UserSession.fb_client(service.token)
      post_args = {:caption => params[:description], :access_token => service.secret , :source => file}
      RestClient.post("https://graph.facebook.com/#{service.fb_page_id}/photos", post_args)
#      client.page("#{service.fb_page_id}").feed(:create, :caption => params[:description], :picture => url )
    rescue Exception => e
    end
  end

  def self.post_photo_to_twitter(params,service,url,stream)
    begin
      #      url = url.gsub("=","^equal_to^");
      #      url = url.gsub("?","^question_mark^");
      #      url = url.gsub("&","^and^");
      #      img_url = self.shorten_bitly(url)
      #      message = params[:title] + "-" + params[:description] + " " + img_url[0]
      message = params[:description] + " https://www.edintity.com/stream/#{stream.id}"
      TwitterAccount.post_twitter_message(message,service,params[:star1])
    rescue
    end
  end

  def self.post_photo_to_tumblr(params,service,url)
    begin
      user = Tumblr::User.new(params["photo_tumblr_email_#{service.id}"], params["photo_tumblr_password_#{service.id}"])
      Tumblr.blog = service.token
      Tumblr::Post.create(user, :type => 'photo', :source => url, :caption => params[:description])
    rescue
    end
  end

  def self.post_video_to_tumblr(params,service,url)
    begin
      user = Tumblr::User.new(params["video_tumblr_email_#{service.id}"], params["video_tumblr_password_#{service.id}"])
      Tumblr.blog = service.token
      embed = "<embed width='500' height='375' type='application/x-shockwave-flash' src='https://media.dreamhost.com/mediaplayer.swf?file=#{url}' quality='high' name='movie_player' flashvars='file=#{url}' autoplay='false'>"
      Tumblr::Post.create(user, :type => 'video', :embed => embed, :caption => params[:title] + " - " + params[:description])
    rescue Exception => e
    end
  end

  def self.post_video_to_facebook(params,service,file)
    begin
      client = UserSession.fb_client(service.token)
      post_args = { 'name' => params[:title], "description" => params[:description], :access_token => service.token , :source => file}
      RestClient.post("https://graph.facebook.com/#{client.me.info['id']}/videos", post_args)
    rescue
    end
  end

  def self.post_video_to_facebook_page(params,service,file)
    begin
      client = UserSession.fb_client(service.token)
      post_args = { 'name' => params[:title], "description" => params[:description], :access_token => service.secret , :source => file}
      RestClient.post("https://graph.facebook.com/#{service.fb_page_id}/videos", post_args)
    rescue
    end
  end

  def self.post_video_to_twitter(params,service,stream,host)
    begin
      message = params[:title] + "-" + params[:description] + " http://#{host}/stream/#{stream.id}"
      TwitterAccount.post_twitter_message(message,service,params[:star1])
    rescue Exception => e
    end
  end

  def self.post_video_to_vimeo(params,service)
    video = Vimeo::Advanced::Upload.new(CONSUMER_KEY, CONSUMER_SECRET, :token => service.token, :secret => service.secret)
    video.upload(params[:file_path])
  end

  def self.post_video_to_youtube(params,service,file)
    client = YouTubeIt::AuthSubClient.new(:token => service.token , :dev_key => DEV_KEY)
    client.video_upload(file, :title => params[:title].blank? ? "Posted from edintity" : params[:title],:description => params[:description], :category => 'People',:keywords => %w[edintity])
  end

  def self.post_to_tumblr(params,current_user,service_id)
    begin
      service = current_user.user_services.find_by_id(service_id.to_i)
#      if params["stream_post_type"] == "Status Update"
#        user = Tumblr::User.new(params["status_tumblr_email_#{service.id}"], params["status_tumblr_password_#{service.id}"])
#      else
#        user = Tumblr::User.new(params["link_tumblr_email_#{service.id}"], params["link_tumblr_password_#{service.id}"])
#      end
#      Tumblr.blog = service.token
#      if params["stream_post_type"] == "Status Update"
#        Tumblr::Post.create(user, :type => 'regular', :body => params["status_update_message"])
#      else
#        Tumblr::Post.create(user, :type => 'link', :description => params["description"], :url => params["title"])
#      end
      if params["stream_post_type"] == "Status Update"
        access_token = tumblr_access_token(service.token, service.secret)
        access_token.post("http://api.tumblr.com/v2/blog/subieth.tumblr.com/post", {:body => params["status_update_message"]})
      else
        access_token = tumblr_access_token(service.token, service.secret)
        access_token.post("http://api.tumblr.com/v2/blog/subieth.tumblr.com/post", {:description => params["description"], :url => params["title"]})
      end
    rescue
    end
  end

  # Share to service with FB
  def self.post_to_facebook(stream, params,current_user,service_id,brand=false)
#    if params["stream_post_type"].downcase == "status"
#      message = params["status_update_message"]
#    else
#      message = params[:title]
#    end
    url = "https://www.edintity.com/stream/#{stream.id}"
    message = "#{params['status_optional_message']} #{self.shorten_bitly(url)}"
    errors = ""
    description = params[:description]
    if !brand
      service = current_user.user_services.facebook_authorized.find(service_id.to_i)
    else
      service = current_user.brand_services.facebook_authorized.find(service_id.to_i)
    end
    client = UserSession.fb_client(service.token)
    client.me.feed(:create, :message => message, :description => description )
    #    if client
    #      Stream.save_facebook_stream_details(client,service,current_user)
    #      [true, errors]
    #    else
    #      errors = "Sorry ! Your tweet failed to sent, try later !"
    #      [false, errors]
    #    end
  end

  # Share to service with FB Page
  def self.post_to_facebook_page(params,current_user,service_id,brand=false)
    begin
      if params["stream_post_type"].downcase == "status"
        message = params["status_update_message"]
      else
        message = params[:title]
      end
      errors = ""
      description = params[:description]
      if !brand
        service = current_user.user_services.facebook_page_authorized.find_by_id(service_id.to_i)
      else
        service = current_user.brand_services.facebook_page_authorized.find_by_id(service_id.to_i)
      end
      unless service.fb_page_id.blank?
        client = UserSession.fb_client(service.secret)
        client.page(service.fb_page_id).feed(:create, :message => message, :description => description )
      end
      #    if client
      #      Stream.save_facebook_stream_details(client,service,current_user)
      #      [true, errors]
      #    else
      #      errors = "Sorry ! Your tweet failed to sent, try later !"
      #      [false, errors]
      #    end
    rescue
    end
  end

  def save_message(params,user,post_type_id)
    @post = Post.create(:user_id => user.id,
      :post_type_id => post_type_id,
      :body_text => params[:status_update_message],
      :star_count => params[:star1])
  end

  #TODO
  # Need to make it dry with save_message
  def save_link(params,user)
    #    post_type_select(type)
    @post = Post.create(:user_id => user.id,
      :post_type_id => 2,
      :body_text => params[:title],
      :star_count => params[:star1])
  end

  def self.shorten_bitly(url)
    # build url to bitly api
    url = url.gsub("^equal_to^", "=")
    url = url.gsub("^question_mark^", "?")
    url = url.gsub("^and^", "&")
    user = "sumeru"
    apikey = "R_1557bd1406a82885437743d1cb5aaffa"
    version = "2.0.1"
    bitly_url = "http://api.bit.ly/shorten?version=#{version}&longUrl=#{url}&login=#{user}&apiKey=#{apikey}"

    buffer = open(bitly_url, "UserAgent" => "Ruby-ExpandLink").read
    result = JSON.parse(buffer)
    [result['results'][url]['shortUrl'], result['results'][url]['errorMessage']]
  end

  #method to post on stumble upon
  def self.post_review_to_stumbleupon username, password, title, description, tags
    to_stumble_upon(
      :username => username,
      :password => password,
      :title => title,
      :description => description,
      :tags => tags,
      :url => "http://your-site.com/a-path"
    )
  end
  
  def self.tumblr_access_token(token, secret)
    consumer = OAuth::Consumer.new('WbI41IN94GLiSkleeWpUbX7cys2xz3Ul6ioFSJs9Zni1ppnugm', 'NrWBAtzJq1XOkSERRygerdxxEOrmV3sbj5kmP9R5dSvlWiamUG',{:site => "http://www.tumblr.com",
        :request_token_path => '/oauth/request_token',
        :authorize_path => '/oauth/authorize',
        :access_token_path => '/oauth/access_token',
        :http_method => :post})
    token_hash = {:oauth_token => token,:oauth_token_secret => secret}
    request_token = OAuth::RequestToken.new(
        consumer, token, secret
      )
      access_token = request_token.get_access_token
      
#    OAuth::AccessToken.from_hash(consumer, token_hash )
	end

  private
  def to_stumble_upon(options = {})
    # fields
    username    = options[:username]
    password    = options[:password]
    title       = options[:title]
    url         = options[:url]
    description = options[:description]
    tags        = options[:tags]

    # crawler
    agent       = Mechanize.new
    agent.user_agent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; ru-ru) AppleWebKit/533.2+ (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10"

    # login
    page = agent.get("http://www.stumbleupon.com/")
    form = page.form_with(:action => "/login.php")
    form["username"] = username
    form["password"] = password
    form.submit

    # basic info
    page = agent.get("http://www.stumbleupon.com/submit?url=#{url}&title=#{title}")
    form = page.forms.first
    form["topic"] = title
    form["comment"] = description
    form.radiobuttons_with(:name => "sfw").first.check
    page = agent.submit(form)

    # add tags
    page = agent.get("http://www.stumbleupon.com/favorites/")
    # get key properties
    token = page.parser.css("div#wrapperContent").first["class"]
    var = page.parser.css("li.listLi var").first
    #comment_id = var["id"]
    #public_id   = var["class"]

    # post to hidden api
    url    = "http://www.stumbleupon.com/ajax/edit/comment"
    params = {
      "syndicate_fb"  =>"syndicate_fb",
      "title"         => title,
      "token"         => token,
      "sticky_post"   => "0",
      "review"        => description,
      "tags"          => tags.join(", "),
      # "publicid"      => public_id,
      "syndicate_tw"  => "syndicate_tw",
      #"commentid"     => comment_id,
      "keep_date"     => "1"
    }

    page   = agent.post(url, params)
    puts page.content
  end
end
